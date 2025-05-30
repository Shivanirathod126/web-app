provider "aws" {
  region = "ap-south-1"  # Mumbai region
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")  # Make sure this file exists
}

resource "aws_security_group" "minikube_sg" {
  name        = "minikube-sg"
  description = "Allow SSH, HTTP and NodePort range"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API Server (optional, for remote kubectl)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort range for Kubernetes"
    from_port   = 30000
    to_port     = 32767
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

resource "aws_instance" "minikube_host" {
  ami                    = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 in ap-south-1
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.minikube_sg.name]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget apt-transport-https docker.io conntrack
              systemctl start docker
              systemctl enable docker

              # Install Minikube
              curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
              install minikube-linux-amd64 /usr/local/bin/minikube

              # Start Minikube with Docker driver
              minikube start --driver=docker
              EOF

  tags = {
    Name = "minikube-host"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 in ap-south-1
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.minikube_sg.name]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y curl wget apt-transport-https docker.io conntrack
              systemctl start docker
              systemctl enable docker
              EOF

  tags = {
    Name = "jenkins-host"
  }
}
