output "access_key_id" {
    value = "${aws_iam_access_key.kops.id}"
}

output "secret_access_key" {
    value = "${aws_iam_access_key.kops.secret}"
}

output "aws_bucket" {
    value = "${var.aws_bucket}"
}
