#
variable "name" {
  description = "The name of the VPC"
}

variable "cidr" {
  description = "The CIDR block for the VPC"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
}
