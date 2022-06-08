resource "aws_instance" "myec2" {
  ami                    = "ami-0ca285d4c2cda3300"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  key_name               = aws_key_pair.deployer.id

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y nginx1",
      "sudo systemctl start nginx"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${aws_instance.myec2.private_ip} >> private_ips.txt"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      #   "/tmp/script.sh args",
      "/tmp/script.sh >> /tmp/output.txt ",
    ]
  }

  tags = {
    Name = "HelloWorld"
  }

}

output "myec2_ip" {
    value = aws_instance.myec2.public_dns
}

output "sg_id" {
    value = aws_security_group.allow_http.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDC6lqxEYXH8WQU6Oumig6S4X35dmEqkXqcUJM3F8ysDiDDZ20X6gExtHD3mdlaBcAOKvDQhfW1GBGVAUlEgR5OvwL5jcf59gqO/os964ldPaA5BI7ge6qmBSWVLJaits0C0kmuOTIU+Flo5UCZRx2TSAvOw6FfsHeCqeIyfFDDJyPjYTZ4vFaPRLA2IAPZUzg48oaZn7742xmL2SvvhJ2H6NyKNbPyKyRCvhxe8m9UTtjRJ10Hig1sI1UqxaGN3wGQbzHJFMl5HgmCMXIWhTh6MeZ83vufkwfHVONI5f/MD5rDpLt60wEUC9vHfOfsrAE41ZvSaC1OAk7D4EETnXfLdJ8NHDppCCKOJLqMjNqjvYDiZDX3KXmfVa8QfLbhJMQDYcKDDIO38VeTkxfGg46f9Kuobl+Fs3rPRNd2yM/kcLr6V2EoOmezcfiASjpDJmEc+qf7xNBQ+c8aYUGsbuUOpOKJ70I4QyyzQDrNIj5mXx3RnXtnBa6CQy/gJGQgzL0= saurava@IN-5CG0472M0Q"
}

locals {
  http_port = 80
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}