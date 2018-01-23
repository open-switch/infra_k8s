variable "aws_access_key_id" {
  type = "string"
}
variable "aws_secret_access_key" {
  type = "string"
}
variable "aws_region" {
  type = "string"
  default = "us-west-2"
}
variable "aws_bucket" {
  type = "string"
  default = "openswitch-net-kops-state-store"
}
