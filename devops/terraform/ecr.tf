resource "aws_ecr_repository" "app" {
  name                 = var.app
  image_tag_mutability = "IMMUTABLE"
}
