# Commented out example ##


resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-s3-alb-logs-${var.environment}-01"
}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_logs.bucket}/*"]
    actions   = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  } 
}
resource "aws_s3_bucket_policy" "alb_logs_policy" {
  policy = data.aws_iam_policy_document.alb_logs.json
  bucket = aws_s3_bucket.alb_logs.id
}

resource "aws_s3_bucket_versioning" "versioning_example-bucket" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

