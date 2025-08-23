data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    region     = var.aws_region
    account_id = data.aws_caller_identity.current.account_id
    api_repo   = aws_ecr_repository.api.repository_url
    web_repo   = aws_ecr_repository.web.repository_url
    project    = var.project
    environment= var.environment
  })

  tags = {
    Name = "${var.project}-${var.environment}-ec2"
  }
}
