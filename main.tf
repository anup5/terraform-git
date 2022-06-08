module "mymodule" {
  source        = "../../modules/ec2"
  instance_type = "t2.large"
}


resource "aws_instance" "myotherec2" {
  ami                    = "ami-0ca285d4c2cda3300"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [module.mymodule.sg_id]
}

output "mysgid" {
    value = module.mymodule.sg_id
}