# Commented out example ##
resource "aws_s3_bucket" "alb_logs" {
  bucket = "my-elb-tf-test-bucket"

  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::054676820928:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}