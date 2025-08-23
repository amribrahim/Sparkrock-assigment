resource "aws_ecr_repository" "api" {
  name                 = "${var.project}-api"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "${var.project}-${var.environment}-api-ecr" }
}

resource "aws_ecr_repository" "web" {
  name                 = "${var.project}-web"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "${var.project}-${var.environment}-web-ecr" }
}
