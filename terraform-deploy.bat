#!/bin/bash

# Exit on any error
set -e

# Define environment variables (do NOT commit these to Git)
export TF_VAR_rds_username="admin"
export TF_VAR_rds_password="YourSecurePassw0rd"

# Initialize Terraform
echo "🚀 Initializing Terraform..."
terraform init

# Validate Terraform files
echo "🔍 Validating Terraform..."
terraform validate

# Plan and apply infrastructure
echo "📦 Applying Terraform configuration..."
terraform apply -auto-approve
