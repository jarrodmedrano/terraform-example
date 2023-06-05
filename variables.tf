variable "TF_VAR_AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
  type        = string
  nullable    = false
}

variable "TF_VAR_AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  nullable    = false
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_subnet" {
  description = "Web Subnet"
  type        = string
  default     = "10.0.10.0/24"
}