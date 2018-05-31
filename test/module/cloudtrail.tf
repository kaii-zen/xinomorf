data "aws_s3_bucket" "this" {
  bucket = "${local.bootstrap_nix_bucket}"
}

resource "aws_cloudtrail" "this" {
  name           = "${var.name}"
  s3_bucket_name = "benbria-cloudtrail"

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = false

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${data.aws_s3_bucket.this.arn}/${local.bootstrap_nix_key}"]
    }
  }
}
