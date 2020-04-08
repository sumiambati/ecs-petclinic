variable "Environment" {
  description = "Environment name"
}

variable "App" {
  description = "Application name"
}

output "tags" {
  value = {
    Application = var.App
    Owner       = "devops"
    Environment = var.Environment
  }
}