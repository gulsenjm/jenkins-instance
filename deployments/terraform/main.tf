provider "aws" {
  version = "2.59"
}

resource "aws_instance" "jenkins" {
  ami           = "${var.ami}"
  instance_type = "t2.micro"
  tags = {
    Name = "${var.Name}"
  }
}
variable "ami" {}
variable "Name" {}