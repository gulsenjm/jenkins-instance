provider "aws" {}
resource "aws_instance" "jenkins" {
    ami = "ami-0e9089763828757e1"
    instance_type = "t2.micro"

    tags = {
      Name = "Jenkins"
    }
}
