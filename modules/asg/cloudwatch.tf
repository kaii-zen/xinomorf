locals {
  event_pattern = {
    source = [
      "aws.s3",
    ]

    detail-type = [
      "AWS API Call via CloudTrail",
    ]

    detail = {
      eventSource = [
        "s3.amazonaws.com",
      ]

      eventName = [
        "PutObject",
        "CopyObject",
      ]

      requestParameters = {
        bucketName = [
          "${local.bootstrap_nix_bucket}",
        ]

        key = ["${local.bootstrap_nix_key}"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name          = "${module.asg.this_autoscaling_group_id}"
  event_pattern = "${jsonencode(local.event_pattern)}"
}

resource "aws_cloudwatch_event_target" "this" {
  arn      = "${aws_ssm_document.nixos_rebuild_switch.arn}"
  rule     = "${aws_cloudwatch_event_rule.this.name}"
  role_arn = "${aws_iam_role.ssm_lifecycle.arn}"

  run_command_targets {
    key    = "tag:Name"
    values = ["${var.name}"]
  }
}
