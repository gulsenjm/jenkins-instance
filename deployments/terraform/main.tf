provider "aws" {
  version = "2.59"
  region = "us-east-1"                                                             
}

resource "aws_instance" "jenkins" {               
   
  ami = "${var.ami}"
  instance_type = "t2.micro"
  tags = {
    Name = "${var.Name}"
  }
}

variable "ami"{}
variable "Name"{}