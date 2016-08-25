variable "key_name" {
  description = "Desired name of AWS key pair"
  default     = "JohnAWS"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  default = "personal"
}

variable "default_az" {
	default = "us-east-1a"
}

variable "default_vpc" {
	default = "vpc-bd7076d9"
}

variable "default_subnet" {
	default = "subnet-9396fbe5"
}
