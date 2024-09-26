provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
    name = "allow_web"
    description = "Allow inbound web traffic"

    ingress {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_mysql" {
    name = "allow_mysql"
    description = "Allow use of mysql connection"

    ingress {
        description = "Mysql from anywhere"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "frontend_server" {
  ami           = "ami-010e83f579f15bba0"
  instance_type = "t2.micro"
  key_name      = "cosc349-2024"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_web.id]

  user_data = templatefile("${path.module}/build-webserver-vm.tpl", { mysql_server_ip = aws_instance.mysql_server.private_ip })

  tags = {
    Name = "WebServer"
  }
}

resource "aws_instance" "backend_server" {
  ami           = "ami-010e83f579f15bba0"
  instance_type = "t2.micro"
  key_name      = "cosc349-2024"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_web.id]

  user_data = templatefile("${path.module}/build-webserver-vm.tpl", { mysql_server_ip = aws_instance.mysql_server.private_ip })

  tags = {
    Name = "WebServer"
  }
}

output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

output "mysql_server_ip" {
  value = aws_instance.mysql_server.public_ip
}