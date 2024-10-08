data "aws_instance" "defaut_vpc_instance" {
  instance_id = "i-instanceid"

}

resource "aws_instance" "myvpc_instance" {
    ami = data.aws_instance.defaut_vpc_instance.id
    instance_type = "t2.micro"
    key_name = "key.pem"
    tags = {
      Name = "new instance"
    }

  
}

output "ami_id" {
  value = data.aws_instance.defaut_vpc_instance.id
}