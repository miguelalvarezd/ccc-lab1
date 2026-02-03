resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group for EC2
resource "aws_security_group" "web_server" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web server - allows HTTP and ICMP"
  vpc_id      = aws_vpc.main.id

  # HTTP inbound rule
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP inbound rule (for ping)
  ingress {
    description = "ICMP from anywhere"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = "ami-0532be01f26a3de55"
  instance_type = "t3.micro"
  key_name      = "vockey"

  # Network configuration
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_server.id]
  associate_public_ip_address = true

  # IAM Instance Profile
  iam_instance_profile = "LabInstanceProfile"

  # Root volume configuration
  root_block_device {
    volume_size = 20
    volume_type = "gp3"

    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  # Enable detailed monitoring (1-minute intervals)
  monitoring = true

  # Optional: User data for basic web server setup
  user_data = <<-EOF
    #!/bin/bash
    # Update the system
    sudo yum update -y

    # Install nginx
    sudo yum install -y nginx

    # Start nginx service
    sudo systemctl start nginx

    # Enable nginx to start on boot
    sudo systemctl enable nginx

    # Get instance ID (works with IMDSv1 and IMDSv2)
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null) || true
    if [ -n "$TOKEN" ]; then
        INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
    else
        INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
    fi
    INSTANCE_ID=$${INSTANCE_ID:-unknown}

    # Create a simple HTML page
    cat > /tmp/index.html << HTML
    <!DOCTYPE html>
    <html>
    <head>
        <title>Lab 1 - Cloud Computing</title>
    </head>
    <body>
        <h1>Welcome to Lab 1!</h1>
        <p><strong>Instance ID:</strong> $${INSTANCE_ID}</p>
    </body>
    </html>
    HTML

    sudo mv /tmp/index.html /usr/share/nginx/html/index.html

    # Restart nginx to serve the new content
    sudo systemctl restart nginx
  EOF

  tags = {
    Name = "${var.project_name}-web-server"
  }

  # Ensure the instance is created after the internet gateway
  depends_on = [aws_internet_gateway.main]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name                = "ec2-high-cpu"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 70
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}

# Accept the VPC peering connection (add to main.tf)
resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = var.peer_vpc_peering_connection_id != null ? 1 : 0
  vpc_peering_connection_id = var.peer_vpc_peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${var.project_name}-vpc-peering-accepter"
  }
}

# Add route to peer VPC (add to main.tf)
resource "aws_route" "peer_route" {
  count                     = var.peer_vpc_cidr != null && var.peer_vpc_peering_connection_id != null ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = var.peer_vpc_peering_connection_id
}