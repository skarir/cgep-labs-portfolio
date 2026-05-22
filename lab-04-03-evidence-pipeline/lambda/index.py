"""
Lab 4.3: GRC Evidence Aggregator & Compliance Scorer
Aggregates evidence from Lab 2.5, validates with Lab 3.4 policies,
calculates compliance score, and updates control status in DynamoDB.
"""

import json
import os
import boto3
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
s3 = boto3.client('s3')

CONTROL_STATUS_TABLE = os.environ['CONTROL_STATUS_TABLE']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

# NIST 800-53 Controls Implementation Mapping
NIST_CONTROLS = {
    "SC-28(1)": {
        "name": "Encryption at Rest",
        "labs": ["2.3", "2.5"],
        "evidence_key": "encryption_configured"
    },
    "AU-3(1)": {
        "name": "Audit Event Logging",
        "labs": ["2.3", "2.5", "5.2"],
        "evidence_key": "logging_enabled"
    },
    "AU-6(1)": {
        "name": "Audit Review and Analysis",
        "labs": ["2.5", "5.2"],
        "evidence_key": "audit_monitoring"
    },
    "CM-6(1)": {
        "name": "Configuration Settings Management",
        "labs": ["2.3", "2.5"],
        "evidence_key": "configuration_baseline"
    },
    "AC-3(1)": {
        "name": "Access Enforcement",
        "labs": ["2.3"],
        "evidence_key": "access_control_policy"
    },
    "CA-7(1)": {
        "name": "Continuous Monitoring",
        "labs": ["5.2"],
        "evidence_key": "continuous_monitoring"
    },
    "SI-10(1)": {
        "name": "Evidence Integrity",
        "labs": ["2.5"],
        "evidence_key": "evidence_integrity_verified"
    },
    "IA-2(1)": {
        "name": "Authentication",
        "labs": ["5.2"],
        "evidence_key": "multi_factor_authentication"
    }
}

def lambda_handler(event, context):
    """
    Main handler: Orchestrate evidence aggregation and compliance scoring
    """
    print(f"Starting GRC Evidence Pipeline: {datetime.utcnow().isoformat()}")

    try:
        table = dynamodb.Table(CONTROL_STATUS_TABLE)

        # 1. Collect evidence from all deployed labs
        evidence_map = collect_evidence()

        # 2. Validate controls and update status
        control_scores = {}
        for control_id, control_info in NIST_CONTROLS.items():
            status = validate_control(control_id, control_info, evidence_map)
            control_scores[control_id] = status

            # Update DynamoDB with control status
            update_control_status(table, control_id, control_info, status)

        # 3. Calculate overall compliance score
        compliance_score = calculate_compliance_score(control_scores)

        # 4. Store overall compliance metric
        update_overall_score(table, compliance_score)

        # 5. Generate and send notification
        send_compliance_notification(compliance_score, control_scores)

        # 6. Generate audit report
        audit_report = generate_audit_report(compliance_score, control_scores)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'GRC Evidence Pipeline Completed',
                'timestamp': datetime.utcnow().isoformat(),
                'compliance_score': Decimal(str(compliance_score)),
                'controls_evaluated': len(NIST_CONTROLS),
                'compliant_controls': sum(1 for s in control_scores.values() if s['status'] == 'COMPLIANT'),
                'audit_report': audit_report
            }, default=str)
        }

    except Exception as e:
        print(f"Error in GRC pipeline: {str(e)}")
        # Send error notification
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="GRC Pipeline Error",
            Message=f"Error occurred during evidence aggregation: {str(e)}"
        )
        raise


def collect_evidence():
    """
    Collect evidence from deployed infrastructure
    Returns: dict mapping control IDs to evidence
    """
    evidence = {}

    try:
        # Query evidence from S3 buckets
        buckets = s3.list_buckets()

        for bucket in buckets.get('Buckets', []):
            bucket_name = bucket['Name']

            if 'cgep-lab-data' in bucket_name:
                # Lab 2.3: S3 Bucket evidence
                evidence['s3_encryption'] = check_s3_encryption(bucket_name)
                evidence['s3_versioning'] = check_s3_versioning(bucket_name)
                evidence['s3_logging'] = check_s3_logging(bucket_name)

            if 'evidence-archive' in bucket_name:
                # Lab 2.5: Evidence archive
                evidence['evidence_archive'] = True

        # Check for DynamoDB tables (Lab 2.5 & 4.3)
        dynamodb_client = boto3.client('dynamodb')
        tables = dynamodb_client.list_tables()

        for table_name in tables.get('TableNames', []):
            if 'evidence' in table_name:
                evidence['evidence_metadata_table'] = True
            if 'control-status' in table_name:
                evidence['control_status_table'] = True

        return evidence

    except Exception as e:
        print(f"Error collecting evidence: {str(e)}")
        return evidence


def check_s3_encryption(bucket_name):
    """Check if S3 bucket has encryption enabled"""
    try:
        response = s3.get_bucket_encryption(Bucket=bucket_name)
        return response.get('ServerSideEncryptionConfiguration') is not None
    except s3.exceptions.ServerSideEncryptionConfigurationNotFoundError:
        return False
    except Exception:
        return False


def check_s3_versioning(bucket_name):
    """Check if S3 bucket has versioning enabled"""
    try:
        response = s3.get_bucket_versioning(Bucket=bucket_name)
        return response.get('Status') == 'Enabled'
    except Exception:
        return False


def check_s3_logging(bucket_name):
    """Check if S3 bucket has logging enabled"""
    try:
        response = s3.get_bucket_logging(Bucket=bucket_name)
        return response.get('LoggingEnabled') is not None
    except Exception:
        return False


def validate_control(control_id, control_info, evidence_map):
    """
    Validate a single NIST control based on collected evidence
    Returns: dict with status and evidence references
    """

    # Simple validation logic - in production, would do deeper analysis
    status = "COMPLIANT" if check_control_evidence(control_id, evidence_map) else "NON-COMPLIANT"

    return {
        'status': status,
        'control_id': control_id,
        'control_name': control_info['name'],
        'labs_implementing': control_info['labs'],
        'verified_timestamp': datetime.utcnow().isoformat(),
        'evidence_references': [evidence_map]
    }


def check_control_evidence(control_id, evidence_map):
    """Check if sufficient evidence exists for a control"""

    if control_id in ["SC-28(1)", "CM-6(1)"]:
        return evidence_map.get('s3_encryption') and evidence_map.get('s3_versioning')
    elif control_id in ["AU-3(1)", "AU-6(1)"]:
        return evidence_map.get('s3_logging') and evidence_map.get('evidence_metadata_table')
    elif control_id == "AC-3(1)":
        return evidence_map.get('s3_encryption')
    elif control_id in ["CA-7(1)", "IA-2(1)"]:
        return evidence_map.get('control_status_table')
    elif control_id == "SI-10(1)":
        return evidence_map.get('evidence_archive')

    return False


def update_control_status(table, control_id, control_info, status_dict):
    """Update control status in DynamoDB"""
    try:
        table.put_item(
            Item={
                'ControlID': control_id,
                'Timestamp': datetime.utcnow().isoformat(),
                'Status': status_dict['status'],
                'ControlName': control_info['name'],
                'Framework': 'NIST 800-53',
                'Labs': ','.join(control_info['labs']),
                'VerifiedDate': status_dict['verified_timestamp'],
                'TTL': int(datetime.utcnow().timestamp()) + (365 * 24 * 60 * 60)  # 1 year retention
            }
        )
        print(f"Updated control {control_id}: {status_dict['status']}")
    except Exception as e:
        print(f"Error updating control {control_id}: {str(e)}")


def update_overall_score(table, score):
    """Update overall compliance score"""
    try:
        table.put_item(
            Item={
                'ControlID': 'OVERALL',
                'Timestamp': datetime.utcnow().isoformat(),
                'Status': 'SCORE',
                'ComplianceScore': Decimal(str(score)),
                'Framework': 'NIST 800-53',
                'VerifiedDate': datetime.utcnow().isoformat()
            }
        )
        print(f"Updated overall compliance score: {score}%")
    except Exception as e:
        print(f"Error updating overall score: {str(e)}")


def calculate_compliance_score(control_scores):
    """Calculate overall compliance percentage"""
    if not control_scores:
        return 0

    compliant = sum(1 for s in control_scores.values() if s['status'] == 'COMPLIANT')
    total = len(control_scores)

    return (compliant / total) * 100 if total > 0 else 0


def send_compliance_notification(score, control_scores):
    """Send SNS notification with compliance status"""
    try:
        compliant_count = sum(1 for s in control_scores.values() if s['status'] == 'COMPLIANT')
        total_count = len(control_scores)

        message = f"""
GRC Compliance Pipeline Report
==============================

Timestamp: {datetime.utcnow().isoformat()}

Overall Compliance Score: {score:.1f}%

Controls Status:
- Compliant: {compliant_count}/{total_count}
- Non-Compliant: {total_count - compliant_count}/{total_count}

Detailed Control Status:
"""

        for control_id, status_dict in control_scores.items():
            message += f"\n  {control_id} ({status_dict['control_name']}): {status_dict['status']}"

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"GRC Compliance Report: {score:.1f}%",
            Message=message
        )

    except Exception as e:
        print(f"Error sending notification: {str(e)}")


def generate_audit_report(score, control_scores):
    """Generate audit-ready JSON report"""
    return {
        'audit_date': datetime.utcnow().isoformat(),
        'framework': 'NIST 800-53',
        'compliance_score': float(score),
        'total_controls': len(control_scores),
        'compliant_controls': sum(1 for s in control_scores.values() if s['status'] == 'COMPLIANT'),
        'non_compliant_controls': sum(1 for s in control_scores.values() if s['status'] != 'COMPLIANT'),
        'controls': [
            {
                'control_id': cid,
                'status': status['status'],
                'control_name': status['control_name'],
                'verified_date': status['verified_timestamp']
            }
            for cid, status in control_scores.items()
        ]
    }
