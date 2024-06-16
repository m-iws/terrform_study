# ------------------------------------------------------------
#  Terraform configuraton
# ------------------------------------------------------------
terraform {
  required_version = ">=1.4.4"
  backend "s3" {
    bucket = "terraform20240609"
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}
# ------------------------------------------------------------
#  Provider
# ------------------------------------------------------------
provider "aws" {
  region = "ap-northeast-1"
}
