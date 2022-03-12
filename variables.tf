variable "aws_region" {
}
variable "vpc_cidr" {
  default = "10.123.0.0/16"
}
variable "public_subnet_cidrs" {
  default = ["10.123.1.0/24", "10.123.3.0/24"]
}
variable "private_subnet_cidrs" {
  default = ["10.123.2.0/24", "10.123.4.0/24"]
}
