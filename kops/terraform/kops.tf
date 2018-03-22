# https://github.com/kubernetes/kops/blob/master/docs/aws.md
#
# aws iam create-group --group-name kops
#
# aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops
# aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops
# aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops
# aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops
# aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
#
# aws iam create-user --user-name kops
#
# aws iam add-user-to-group --user-name kops --group-name kops
#
# aws iam create-access-key --user-name kops
#
# aws s3api create-bucket \
#     --bucket openswitch-net-kops-state-store \
#     --region us-west-2 \
#     --create-bucket-configuration LocationConstraint=us-west-2
#
# aws s3api put-bucket-versioning \
#     --bucket openswitch-net-kops-state-store \
#     --versioning-configuration Status=Enabled

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_iam_group" "kops" {
  name = "opx-openswitch-net-kops"
}

resource "aws_iam_group_policy_attachment" "kops_ec2" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_r53" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_s3" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_iam" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_vpc" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_group_policy_attachment" "kops_dynamodb" {
  group      = "${aws_iam_group.kops.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_user" "kops" {
  name = "opx-openswitch-net-kops"
}

resource "aws_iam_group_membership" "kops" {
  name = "opx-openswitch-net-kops"

  users = [
    "${aws_iam_user.kops.name}",
  ]

  group = "${aws_iam_group.kops.name}"
}

resource "aws_iam_access_key" "kops" {
  user = "${aws_iam_user.kops.name}"
}

resource "aws_s3_bucket" "kops" {
  bucket        = "${var.aws_bucket}"
  region        = "${var.aws_region}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
