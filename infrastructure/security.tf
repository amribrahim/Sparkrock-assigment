resource "aws_security_group" "instance_sg" {
  name        = "${var.project}-${var.environment}-instance-sg"
  description = "Allow HTTPS (and optional HTTP redirect) to reverse proxy"
  vpc_id      = aws_vpc.main.id

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP (used only to redirect HTTP->HTTPS; remove if you truly want HTTPS-only at SG level)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.environment}-instance-sg" }
}
