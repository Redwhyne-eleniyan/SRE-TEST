import json
import boto3
import logging

# Initialize clients
ec2_client = boto3.client('ec2')
sns_client = boto3.client('sns')

# Constants
INSTANCE_ID = 'i-0eefcfa3c0c35eb0a'
SNS_TOPIC_ARN = 'arn:aws:sns:us-east-1:100503247453:ec2restart'

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        # Restart the EC2 instance
        ec2_client.reboot_instances(InstanceIds=[INSTANCE_ID])
        logger.info(f"EC2 instance {INSTANCE_ID} has been restarted.")
        
        # Publish to SNS topic
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"EC2 instance {INSTANCE_ID} has been restarted by the Lambda function.",
            Subject='EC2 Instance Restart Notification'
        )
        logger.info("SNS notification sent.")
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")

    return {
        'statusCode': 200,
        'body': 'EC2 instance restarted and notification sent.'
    }
