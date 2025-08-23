data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    project     = var.project
    environment = var.environment
    region      = var.aws_region
    account_id  = data.aws_caller_identity.current.account_id
    api_repo    = "${aws_ecr_repository.api.repository_url}:latest"
    web_repo    = "${aws_ecr_repository.web.repository_url}:latest"
  })

  user_data_replace_on_change = true

  tags = {
    Name        = "${var.project}-${var.environment}-instance"
    Project     = var.project
    Environment = var.environment
  }
}
