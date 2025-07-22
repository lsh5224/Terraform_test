resource "aws_ecr_repository" "repos" {
  for_each = toset(var.ecr_repositories)

  name = each.key

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "OneTouch"
  }

  lifecycle {
    ignore_changes  = all
    #prevent_destroy = true
  }
}

variable "ecr_repositories" {
  default = ["backend-boards", "backend-user", "frontend"]
}