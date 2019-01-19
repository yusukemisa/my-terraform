variable "ACCESS_KEY" {}
variable "SECRET_KEY" {}
variable "REGION" {
  default = "us-east-1"
}

# mapの定義も可能
variable "amis" {
  type = "map"
  default = {
    # "key" = "value"
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
provider "aws" {
  access_key = "${var.ACCESS_KEY}"
  secret_key = "${var.SECRET_KEY}"
  region     = "${var.REGION}"
}

# Change the aws_instance we declared earlier to now include "depends_on"
resource "aws_instance" "example" {
  # mapを参照: lookup(var.{map名}, var.{key})
  ami           = "${lookup(var.amis, var.REGION)}"
  instance_type = "t2.micro"

  # Tells Terraform that this EC2 instance must be created only after the
  # S3 bucket has been created.
  depends_on = ["aws_s3_bucket.example"]

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}

# New resource for the S3 bucket our application will use.
resource "aws_s3_bucket" "example" {
  # NOTE: S3 bucket names must be unique across _all_ AWS accounts, so
  # this name must be changed before applying this example to avoid naming
  # conflicts.
  bucket = "terraform-gsg-yusukemisawa1"
  acl    = "private"
}