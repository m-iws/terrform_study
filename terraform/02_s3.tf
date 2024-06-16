# ------------------------------------------------------------#
#  s3
# ------------------------------------------------------------#
resource "aws_s3_bucket" "terraform_study_s3" {
  bucket = "terraform-study-20240609"
  tags = {
    Name = "${var.tag_name}-s3"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket                  = aws_s3_bucket.terraform_study_s3.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
