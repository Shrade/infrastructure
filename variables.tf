variable "environment" {
  type = string
  default = "production"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_role_arn" {
  type = string
}