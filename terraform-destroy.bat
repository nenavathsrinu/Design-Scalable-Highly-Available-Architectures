#!/bin/bash

# Exit on any error
set -e

# Environment variables again
export TF_VAR_rds_username="admin"
export TF_VAR_rds_password="YourSecurePassw0rd"

# Destroy all infrastructure
echo "🔥 Destroying Terraform resources..."
terraform destroy -auto-approve
