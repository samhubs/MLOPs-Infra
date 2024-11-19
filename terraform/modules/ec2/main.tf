resource "aws_key_pair" "instance_key" {
  key_name   = "${var.environment}-key"
  public_key = tls_private_key.instance_key.public_key_openssh
}

# Generate private key
resource "tls_private_key" "instance_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.instance_key.private_key_pem
  filename        = "${path.module}/${var.environment}-key.pem"
  file_permission = "0400"  # Set proper permissions
}

# Security Group
resource "aws_security_group" "main" {
  name        = "${var.environment}-instance-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Consider restricting this to your IP
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-instance-sg"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  key_name = aws_key_pair.instance_key.key_name
  
  vpc_security_group_ids = [aws_security_group.main.id]
  
  # Enable public IP
  associate_public_ip_address = true

  # User data to ensure SSH access
  user_data = <<-EOF
              #!/bin/bash
              sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF

  tags = {
    Name = "${var.environment}-instance"
  }
}

# Output the connection command
output "ssh_command" {
  value = "ssh -i ${path.module}/${var.environment}-key.pem ec2-user@${aws_instance.main.public_ip}"
}