provider "aws" {}
resource "aws_instance" "jenkins" {
    ami = "ami-016b213e65284e9c9"
    instance_type = "t2.micro"

    tags = {
      Name = "Jenkins"
    }
}
