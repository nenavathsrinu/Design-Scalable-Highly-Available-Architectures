terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-nttdata"
    key            = "env/dev/terraform.tfstate"  # Change per env
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}