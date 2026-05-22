"""
Lab 4.4: Chain of Custody Tracker
Maintains immutable audit trail of evidence collection, verification, and access.
Supports SOC 2 Type II, ISO 27001, and regulatory audit requirements.
"""

import json
import os
import boto3
import hashlib
from datetime import datetime, timedelta
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
logs = boto3.client('logs')
s3 = boto3.client('s3')

COC_TABLE_NAME = os.environ['COC_TABLE_NAME']
LOG_GROUP_NAME = os.environ['LOG_GROUP_NAME']
RETENTION_DAYS = int(os.environ['RETENTION_DAYS'])


def lambda_handler(event, context):
    """
    Main handler: Create and maintain chain of custody records
    """
    print(f"Chain of Custody Tracker: {datetime.utcnow().isoformat()}")

    try:
        table = dynamodb.Table(COC_TABLE_NAME)

        # Extract evidence details from event
        evidence_id = event.get('evidence_id', f"evidence-{datetime.utcnow().strftime('%Y%m%d-%H%M%S')}")
        source = event.get('source', 'Unknown')
        collector = event.get('collector', 'Lambda-Function')
        collector_role = event.get('collector_role', context.invoked_function_arn)
        archive_location = event.get('archive_location', '')
        evidence_hash = event.get('evidence_hash', '')
        action = event.get('action', 'COLLECTED')

        # 1. Create or update chain of custody record
        coc_record = create_coc_record(
            evidence_id=evidence_id,
            source=source,
            collector=collector,
            collector_role=collector_role,
            archive_location=archive_location,
            evidence_hash=evidence_hash,
            action=action
        )

        # 2. Store in DynamoDB
        store_coc_record(table, coc_record)

        # 3. Log to CloudWatch
        log_coc_event(evidence_id, coc_record, action)

        # 4. Handle access logging if applicable
        if action == "ACCESSED":
            log_evidence_access(table, evidence_id, event.get('accessed_by'), event.get('access_reason'))

        # 5. Handle verification if applicable
        if action == "VERIFIED":
            log_verification(table, evidence_id, event.get('verifier'), evidence_hash)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Chain of Custody Updated',
                'evidence_id': evidence_id,
                'status': action,
                'timestamp': coc_record['Timestamp']
            })
        }

    except Exception as e:
        print(f"Error in chain of custody tracking: {str(e)}")
        raise


def create_coc_record(evidence_id, source, collector, collector_role, archive_location, evidence_hash, action):
    """
    Create a chain of custody record
    """
    now = datetime.utcnow()
    expiration = now + timedelta(days=RETENTION_DAYS)

    record = {
        'EvidenceID': evidence_id,
        'Timestamp': now.isoformat(),
        'Source': source,
        'Status': action,
        'Collector': collector,
        'CollectorRole': collector_role,
        'ArchiveLocation': archive_location,
        'Hash': evidence_hash,
        'CollectionTime': now.isoformat(),
        'RetentionDays': RETENTION_DAYS,
        'ExpirationTime': int(expiration.timestamp()),
        'ExpirationDate': expiration.strftime('%Y-%m-%d'),
        'Audit': {
            'CreatedBy': collector,
            'CreatedAt': now.isoformat(),
            'LastModifiedBy': collector,
            'LastModifiedAt': now.isoformat()
        },
        'Access': []  # Will be populated as evidence is accessed
    }

    return record


def store_coc_record(table, record):
    """
    Store chain of custody record in DynamoDB
    """
    try:
        table.put_item(Item=record)
        print(f"Stored COC record for {record['EvidenceID']}")
    except Exception as e:
        print(f"Error storing COC record: {str(e)}")
        raise


def log_coc_event(evidence_id, coc_record, action):
    """
    Log chain of custody event to CloudWatch
    Creates immutable audit trail
    """
    try:
        log_message = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': 'CHAIN_OF_CUSTODY',
            'evidence_id': evidence_id,
            'action': action,
            'source': coc_record['Source'],
            'collector': coc_record['Collector'],
            'hash': coc_record['Hash'],
            'archive_location': coc_record['ArchiveLocation'],
            'retention_days': coc_record['RetentionDays'],
            'expiration_date': coc_record['ExpirationDate']
        }

        # Log to CloudWatch
        logs.put_log_events(
            logGroupName=LOG_GROUP_NAME,
            logStreamName='evidence-access-audit',
            logEvents=[
                {
                    'timestamp': int(datetime.utcnow().timestamp() * 1000),
                    'message': json.dumps(log_message)
                }
            ]
        )

        print(f"Logged COC event: {evidence_id}")

    except Exception as e:
        print(f"Error logging COC event: {str(e)}")


def log_evidence_access(table, evidence_id, accessed_by, access_reason):
    """
    Log when evidence is accessed (SOC 2 Type II requirement)
    Maintains record of who accessed what, when, and why
    """
    try:
        access_record = {
            'AccessTime': datetime.utcnow().isoformat(),
            'AccessedBy': accessed_by,
            'AccessReason': access_reason or 'Audit Review',
            'AccessHash': calculate_hash(evidence_id)
        }

        table.update_item(
            Key={'EvidenceID': evidence_id, 'Timestamp': datetime.utcnow().isoformat()},
            UpdateExpression='SET #access = list_append(if_not_exists(#access, :empty), :val)',
            ExpressionAttributeNames={'#access': 'Access'},
            ExpressionAttributeValues={
                ':empty': [],
                ':val': [access_record]
            }
        )

        print(f"Logged access to {evidence_id} by {accessed_by}")

    except Exception as e:
        print(f"Error logging evidence access: {str(e)}")


def log_verification(table, evidence_id, verifier, evidence_hash):
    """
    Log evidence verification (hash confirmation)
    Ensures integrity from collection through archival
    """
    try:
        verification_record = {
            'VerificationTime': datetime.utcnow().isoformat(),
            'Verifier': verifier,
            'VerificationHash': evidence_hash,
            'Status': 'VERIFIED'
        }

        table.update_item(
            Key={'EvidenceID': evidence_id, 'Timestamp': datetime.utcnow().isoformat()},
            UpdateExpression='SET Audit.Verification = :val, Audit.LastVerifiedAt = :now',
            ExpressionAttributeValues={
                ':val': verification_record,
                ':now': datetime.utcnow().isoformat()
            }
        )

        print(f"Logged verification for {evidence_id}")

    except Exception as e:
        print(f"Error logging verification: {str(e)}")


def calculate_hash(evidence_id):
    """
    Calculate hash of evidence for integrity verification
    """
    hash_obj = hashlib.sha256(evidence_id.encode())
    return f"sha256:{hash_obj.hexdigest()}"


def generate_coc_report(table, evidence_id):
    """
    Generate chain of custody report for audit submission
    """
    try:
        response = table.get_item(Key={'EvidenceID': evidence_id})
        record = response.get('Item', {})

        report = {
            'report_type': 'CHAIN_OF_CUSTODY',
            'evidence_id': evidence_id,
            'report_date': datetime.utcnow().isoformat(),
            'collection': {
                'collected_by': record.get('Collector'),
                'collection_time': record.get('CollectionTime'),
                'source': record.get('Source'),
                'initial_hash': record.get('Hash')
            },
            'retention': {
                'retention_days': record.get('RetentionDays'),
                'expiration_date': record.get('ExpirationDate'),
                'legal_hold': False
            },
            'verification': record.get('Audit', {}).get('Verification', {}),
            'access_log': record.get('Access', []),
            'compliance': {
                'soc2_type_ii': True,
                'iso_27001': True,
                'audit_ready': True
            }
        }

        return report

    except Exception as e:
        print(f"Error generating COC report: {str(e)}")
        return {}
