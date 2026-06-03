# Security group allowing SSH for lab validation.
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Security group for Terraform beginner EC2 lab"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH access for lab validation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Project     = var.project_name
    Environment = "training"
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "web" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = cidrsubnet(data.aws_vpc.default.cidr_block, 8, 10)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-subnet"
    Project     = var.project_name
    Environment = "training"
    ManagedBy   = "terraform"
  }
}

# EC2 instance created by Terraform.
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.web.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  tags = {
    Name        = "${var.project_name}-ec2"
    Project     = var.project_name
    Environment = "training"
    ManagedBy   = "terraform"
  }
}
