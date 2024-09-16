resource "aws_instance" "bistroflowEC2" {
  ami           = "ami-0a07ff89aacad043e" 
  instance_type = "t2.large"

  key_name      = "Bistroflow"

  user_data = <<-EOF
    #!/bin/bash
    # Update and install required packages
    sudo apt-get update -y
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    # Clone the GitHub repository
    cd /home/ubuntu/
    git clone https://github.com/yashdek-07/bistroflow-docker.git

    # Navigate to the directory containing docker-compose.yml
    cd /home/ubuntu/bistroflow-docker

    # Run Docker Compose to start the containers
    sudo docker compose up -d --build
  EOF

  tags = {
    Name = "bistroflow-ec2"
  }
}

# Security Group to allow HTTP, Spring Boot, and PostgreSQL access
resource "aws_security_group" "allow_http" {
  name_prefix = "http"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22  # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
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
#Elastic IP

data "aws_eip" "existingEIP" {
  public_ip = "15.168.206.200"
}

resource "aws_eip_association" "connectWithEc2" {
  instance_id   = aws_instance.bistroflowEC2.id
  allocation_id = data.aws_eip.existingEIP.id

}