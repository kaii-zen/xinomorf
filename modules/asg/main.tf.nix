{ var, locals, provider, resource, data, variable, module }:

[
  (provider "aws" {
    version = "~> 1.16";
    region  = "\${var.aws_region}";
  })

  (data "aws_subnet_ids" "subnet" {
    vpc_id = "vpc-bbbf3bc2";
  })

  (variable "aws_region" {
    default = "us-east-1";
  })

  (variable "name" {
    type = "string";
  })

  (variable "desired" {
    type = "string";
  })

  (variable "s3_bucket" {
    type = "string";
  })

  (variable "s3_prefix" {
    type = "string";
    default = "asg";
  })

  (module "role" {
    source = "github.com/Smartbrood/terraform-aws-ec2-iam-role";
    name   = "\${var.name}-iam-role";

    policy_arn = [
      "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      "arn:aws:iam::092288472643:policy/AllowDescribeTags"
    ];
  })

  (module "ami" {
    source  = "github.com/terraform-community-modules/tf_aws_nixos_ami";
    release = "18.03";
  })

  (module "asg" {
    source = "github.com/terraform-aws-modules/terraform-aws-autoscaling";
    name   = "\${var.name}";

    # Launch configuration
    spot_price      = "1.00";
    key_name        = "benbria";
    image_id        = "\${module.ami.ami_id}";
    instance_type   = "m4.large";
    security_groups = ["sg-5f2a942e"];

    ebs_block_device = [
      {
        device_name           = "/dev/xvdz";
        volume_type           = "gp2";
        volume_size           = "50";
        delete_on_termination = true;
      }
    ];

    root_block_device = [
      {
        volume_size = "50";
        volume_type = "gp2";
      }
    ];

    # Auto scaling group
    vpc_zone_identifier       = "\${data.aws_subnet_ids.subnet.ids}";
    health_check_type         = "EC2";
    min_size                  = 0;
    max_size                  = 3;
    desired_capacity          = "\${var.desired}";
    wait_for_capacity_timeout = 0;

    user_data            = "\${data.template_file.userdata_nix.rendered}";
    iam_instance_profile = "\${module.role.profile_name}";

    tags = [
      {
        key                 = "Environment";
        value               = "dev";
        propagate_at_launch = true;
      }
    ];
  })

  (data "template_file" "userdata_nix" {
    template = ''''${file("''${path.module}/userdata.nix.tpl")}'';

    vars = {
      url    = "\${local.bootstrap_nix_url}";
    };
  })

  (locals {
    bootstrap            = "${var.bootstrap}";
    bootstrap_nix_bucket = "\${aws_s3_bucket_object.bootstrap_nix.bucket}";
    bootstrap_nix_key    = "\${aws_s3_bucket_object.bootstrap_nix.key}";
    bootstrap_nix_url    = "s3://\${local.bootstrap_nix_bucket}/\${local.bootstrap_nix_key}";
    bootstrap_nix_sha256 = "\${base64sha256(file(local.bootstrap))}";
    bootstrap_nix_md5    = "\${md5(file(local.bootstrap))}";
  })

  (resource "aws_s3_bucket_object" "bootstrap_nix" {
    bucket = "\${var.s3_bucket}";
    key    = "\${var.s3_prefix}/\${var.name}/nixexprs.tar.bz2";
    source = "\${local.bootstrap}";
    etag   = "\${local.bootstrap_nix_md5}";
  })
]
