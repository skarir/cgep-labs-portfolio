"""
Lab 2.5: Evidence Collector Lambda
Purpose: Collect and archive compliance evidence from Lab 2.3 S3 bucket
Controls: AU-3, AU-6, SC-28, SI-10
"""

import json
import boto3
import hashlib
import os
from datetime import datetime, timezone

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

EVIDENCE_BUCKET = os.environ['EVIDENCE_BUCKET']
METADATA_TABLE = os.environ['METADATA_TABLE']
SOURCE_BUCKET = os.environ['SOURCE_BUCKET']
COLLECTION_DATE = os.environ['COLLECTION_DATE']


def lambda_handler(event, context):
    """
    Main handler for evidence collection
    Collects Terraform state, S3 bucket configuration, and compliance artifacts
    """

    print(f"Evidence Collection Started: {COLLECTION_DATE}")

    evidence_id = f"evidence-{datetime.now(timezone.utc).isoformat()}"
    collected_evidence = []

    try:
        # ========================================
        # 1. Collect S3 Bucket Configuration
        # ========================================
        print("Collecting S3 bucket configuration...")

        s3_evidence = {
            "type": "s3_configuration",
            "bucket": SOURCE_BUCKET,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "controls": ["SC-28(1)", "AU-3(1)", "AU-6(1)", "AC-3(1)", "CM-6(1)"],
            "evidence": {}
        }

        # Get bucket encryption
        try:
            encryption = s3_client.get_bucket_encryption(Bucket=SOURCE_BUCKET)
            s3_evidence["evidence"]["encryption"] = encryption['ServerSideEncryptionConfiguration']
        except Exception as e:
            print(f"Could not retrieve encryption: {str(e)}")

        # Get bucket versioning
        try:
            versioning = s3_client.get_bucket_versioning(Bucket=SOURCE_BUCKET)
            s3_evidence["evidence"]["versioning"] = versioning
        except Exception as e:
            print(f"Could not retrieve versioning: {str(e)}")

        # Get bucket logging
        try:
            logging = s3_client.get_bucket_logging(Bucket=SOURCE_BUCKET)
            s3_evidence["evidence"]["logging"] = logging
        except Exception as e:
            print(f"Could not retrieve logging: {str(e)}")

        # Get public access block
        try:
            public_block = s3_client.get_public_access_block(Bucket=SOURCE_BUCKET)
            s3_evidence["evidence"]["public_access_block"] = public_block['PublicAccessBlockConfiguration']
        except Exception as e:
            print(f"Could not retrieve public access block: {str(e)}")

        collected_evidence.append(s3_evidence)

        # ========================================
        # 2. Archive Evidence to Evidence Bucket
        # ========================================
        print("Archiving evidence...")

        evidence_json = json.dumps(collected_evidence, indent=2, default=str)
        evidence_key = f"lab23-evidence/{COLLECTION_DATE}/{evidence_id}.json"

        # Calculate evidence hash for integrity verification
        evidence_hash = hashlib.sha256(evidence_json.encode()).hexdigest()

        s3_client.put_object(
            Bucket=EVIDENCE_BUCKET,
            Key=evidence_key,
            Body=evidence_json,
            ContentType='application/json',
            Metadata={
                'Evidence-Hash': evidence_hash,
                'Collection-Date': COLLECTION_DATE,
                'Source-Bucket': SOURCE_BUCKET,
                'Controls': 'SC-28,AU-3,AU-6,SI-10',
                'Lab': 'Lab-2.5'
            }
        )

        print(f"Evidence archived to: s3://{EVIDENCE_BUCKET}/{evidence_key}")

        # ========================================
        # 3. Record Evidence Metadata in DynamoDB
        # ========================================
        print("Recording evidence metadata...")

        table = dynamodb.Table(METADATA_TABLE)

        for evidence_item in collected_evidence:
            metadata = {
                'EvidenceID': evidence_id,
                'Timestamp': datetime.now(timezone.utc).isoformat(),
                'ControlID': 'SC-28,AU-3,AU-6,SI-10',
                'EvidenceType': evidence_item['type'],
                'SourceBucket': SOURCE_BUCKET,
                'ArchiveLocation': f"s3://{EVIDENCE_BUCKET}/{evidence_key}",
                'EvidenceHash': evidence_hash,
                'CollectionDate': COLLECTION_DATE,
                'Status': 'COLLECTED',
                'ExpirationTime': int(datetime.now(timezone.utc).timestamp()) + (2555 * 86400)  # 7 years
            }

            table.put_item(Item=metadata)
            print(f"Metadata recorded: {evidence_id}")

        # ========================================
        # 4. Return Success Response
        # ========================================
        response = {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Evidence collection successful',
                'evidence_id': evidence_id,
                'evidence_count': len(collected_evidence),
                'archive_location': f"s3://{EVIDENCE_BUCKET}/{evidence_key}",
                'evidence_hash': evidence_hash,
                'timestamp': datetime.now(timezone.utc).isoformat()
            })
        }

        print(f"Evidence collection completed: {evidence_id}")
        return response

    except Exception as e:
        print(f"ERROR: Evidence collection failed: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Evidence collection failed',
                'message': str(e)
            })
        }
