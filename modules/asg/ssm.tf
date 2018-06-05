data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ssm_lifecycle_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ssm_lifecycle" {
  statement {
    effect  = "Allow"
    actions = ["ssm:SendCommand"]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/*"
      values   = ["${var.name}"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["${aws_ssm_document.nixos_rebuild_switch.arn}"]
  }
}

resource "aws_iam_role" "ssm_lifecycle" {
  name_prefix        = "${title(var.name)}-SSMLifecycle"
  assume_role_policy = "${data.aws_iam_policy_document.ssm_lifecycle_trust.json}"
}

resource "aws_iam_policy" "ssm_lifecycle" {
  name_prefix = "${title(var.name)}-SSMLifecycle"
  policy      = "${data.aws_iam_policy_document.ssm_lifecycle.json}"
}

resource "aws_iam_role_policy_attachment" "ssm_lifecycle" {
  role       = "${aws_iam_role.ssm_lifecycle.name}"
  policy_arn = "${aws_iam_policy.ssm_lifecycle.arn}"
}

locals {
  nix_rebuild_switch = {
    schemaVersion = "2.2"
    description   = ""
    parameters    = {}

    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "nixosRebuildSwitch"

        inputs = {
          runCommand = [
            "/run/current-system/sw/bin/nix-channel --update",
            "/run/current-system/sw/bin/nixos-rebuild switch",
          ]
        }
      },
    ]
  }
}

resource "aws_ssm_document" "nixos_rebuild_switch" {
  name          = "${title(var.name)}-NixOS-RebuildSwitch"
  document_type = "Command"

  content = "${jsonencode(local.nix_rebuild_switch)}"
}
