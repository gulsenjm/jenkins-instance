provider "aws" {}
resource "aws_instance" "jenkins" {
    ami = "ami-08f3d892de259504d"
    instance_type = "t2.micro"

    tags = {
      Name = "Jenkins"
    }
}
