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

variable "subnet_zone" {
  description = "Subnet Zone"
  type        = string
  default     = "us-east-2a"
}

variable "main_vpc_name" {
  description = "Main VPC Name"
  type        = string
  default     = "Main VPC"
}

variable "my_public_ip" {
  description = "My Public IP"
  type        = string
  default     = "162.229.210.89"
}