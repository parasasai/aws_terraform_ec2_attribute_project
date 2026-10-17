variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "eu-central-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "The sizing type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  description = "The inbound port to open on the security group"
  type        = number
  default     = 80
}
