variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
}

variable "azs" {
  type        = list(string)
  default     = []
  description = "List of availability zones"
}

variable "public_subnets" {
  type        = list(string)
  default     = []
  description = "List of public subnets"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}