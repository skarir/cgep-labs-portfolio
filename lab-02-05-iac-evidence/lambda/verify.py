"""
Lab 2.5: Evidence Verification Lambda
Purpose: Verify evidence integrity and completeness
Controls: SI-10 (Evidence integrity and availability)
"""

import json
import boto3
import hashlib
from datetime import datetime, timezone

s3_client = boto3.client('s3')

EVIDENCE_BUCKET = os.environ.get('EVIDENCE_BUCKET', '')


def verify_evidence_hash(bucket, key, metadata_hash):
    """Verify evidence hash for integrity"""
    try:
        response = s3_client.get_object(Bucket=bucket, Key=key)
        file_content = response['Body'].read()
        calculated_hash = hashlib.sha256(file_content).hexdigest()

        if calculated_hash == metadata_hash:
            return True, "Hash verification passed"
        else:
            return False, f"Hash mismatch. Expected: {metadata_hash}, Got: {calculated_hash}"
    except Exception as e:
        return False, f"Hash verification error: {str(e)}"


def verify_evidence_completeness(bucket, prefix):
    """Verify evidence collection completeness"""
    try:
        response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)

        if 'Contents' not in response:
            return False, "No evidence files found"

        evidence_files = response['Contents']
        total_size = sum(obj['Size'] for obj in evidence_files)

        if len(evidence_files) > 0 and total_size > 100:
            return True, f"Evidence complete: {len(evidence_files)} files, {total_size} bytes"
        else:
            return False, "Evidence incomplete: insufficient data collected"
    except Exception as e:
        return False, f"Completeness check error: {str(e)}"


def lambda_handler(event, context):
    """
    Verify evidence integrity and completeness
    SI-10 Control: Maintain evidence integrity and availability
    """

    print("Evidence Verification Started")

    verification_id = f"verification-{datetime.now(timezone.utc).isoformat()}"
    verification_results = {
        'verification_id': verification_id,
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'checks': []
    }

    try:
        # ========================================
        # 1. Verify Recent Evidence Files
        # ========================================
        print("Verifying evidence files...")

        response = s3_client.list_objects_v2(
            Bucket=EVIDENCE_BUCKET,
            Prefix='lab23-evidence/',
            MaxKeys=10
        )

        if 'Contents' in response:
            for obj in response['Contents']:
                print(f"Verifying: {obj['Key']}")

                # Get object metadata
                metadata = s3_client.head_object(Bucket=EVIDENCE_BUCKET, Key=obj['Key'])
                metadata_hash = metadata['Metadata'].get('Evidence-Hash', 'UNKNOWN')

                # Verify integrity
                is_valid, message = verify_evidence_hash(EVIDENCE_BUCKET, obj['Key'], metadata_hash)

                verification_results['checks'].append({
                    'file': obj['Key'],
                    'size': obj['Size'],
                    'last_modified': obj['LastModified'].isoformat(),
                    'integrity_verified': is_valid,
                    'message': message
                })

        # ========================================
        # 2. Verify Evidence Bucket Accessibility
        # ========================================
        print("Verifying evidence bucket accessibility...")

        try:
            s3_client.head_bucket(Bucket=EVIDENCE_BUCKET)
            bucket_accessible = True
            bucket_message = "Evidence bucket is accessible"
        except Exception as e:
            bucket_accessible = False
            bucket_message = f"Bucket access error: {str(e)}"

        verification_results['checks'].append({
            'check': 'bucket_accessibility',
            'bucket': EVIDENCE_BUCKET,
            'accessible': bucket_accessible,
            'message': bucket_message
        })

        # ========================================
        # 3. Verify Evidence Completeness
        # ========================================
        print("Verifying evidence completeness...")

        is_complete, completeness_message = verify_evidence_completeness(
            EVIDENCE_BUCKET,
            'lab23-evidence/'
        )

        verification_results['checks'].append({
            'check': 'completeness',
            'complete': is_complete,
            'message': completeness_message
        })

        # ========================================
        # 4. Return Verification Results
        # ========================================
        overall_status = all(
            check.get('integrity_verified', check.get('accessible', check.get('complete', False)))
            for check in verification_results['checks']
        )

        verification_results['overall_status'] = 'VERIFIED' if overall_status else 'FAILED'

        print(f"Verification complete: {verification_results['overall_status']}")

        return {
            'statusCode': 200 if overall_status else 400,
            'body': json.dumps(verification_results, default=str)
        }

    except Exception as e:
        print(f"ERROR: Verification failed: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Verification process failed',
                'message': str(e),
                'verification_id': verification_id
            })
        }
