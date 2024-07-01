# SRE TEST
This repository contains the solution for the SRE Coding Test Q3 2024. The task is to create a monitoring and automation solution to identify and resolve performance issues in a web application. The solution includes setting up a Sumo Logic query and alert, writing an AWS Lambda function to automate responses, and using Terraform for Infrastructure as Code (IaC) setup.
This project aims to monitor and automate the resolution of performance issues in a web application. The tasks are divided into three parts:
Sumo Logic Query and Alert,
AWS Lambda Function,
Infrastructure as Code (IaC) Setup with Terraform
# Prerequisites
Sumo Logic account
AWS account with IAM permissions to create Lambda functions, EC2 instances, and SNS topics
Terraform installed
Basic knowledge of Python and Terraform
Screen recording software (e.g., Zoom, OBS Studio)
# Part 1: Sumo Logic Query and Alert
Write and Test the Sumo Logic Query:
Go to the Search tab in Sumo Logic and create a new search with the following query
_sourceCategory="Simulated Logs Source"
| parse "response_time=* " as response_time
| parse "endpoint=* " as endpoint
| where endpoint="/api/data" and response_time > 3000
| count by _timeslice
| where _count > 5

# Create and Configure the Alert:

Set up an alert in Sumo Logic to trigger if more than 5 log entries are detected within a 10-minute window.
Configure notifications (e.g., email, webhook).

# AWS Lambda Function
Write the Lambda Function (Python):
Create a file named lambda_function.py
Deploy the Lambda function using the AWS Management Console or CLI.
Test the function to ensure it restarts the EC2 instance and sends the notification.
# IaC Setup with Terraform
Write Terraform Configuration:
Create a file named main.tf
Deploy the Terraform Configuration:
Initialize, plan and apply the Terraform configuration