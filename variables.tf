variable "azs" {
    description = "A list of availability zones in which to create the VPC subnets."
    type        = list(string)
    default     = ["us-west-2a", "us-west-2b"]
}
variable "private_subnets" {
    description = "A list of CIDR blocks for the private subnets."
    type        = list(string)
    default     = ["10.0.1.0/24"]
}
variable "public_subnets" {
    description = "A list of CIDR blocks for the public subnets."
    type        = list(string)
    default     = ["10.0.101.0/24"]
}
variable "vpc_name" {
    description = "The name of the VPC."
    type        = string
    default     = "Bastion Server VPC"
}
variable "vpc_cidr" {
    description = "The CIDR block for the VPC."
    type        = string
    default     = "10.0.0.0/16"
}
variable "enable_nat_gateway" {
    description = "Enable NAT Gateway for private subnets."
    type        = bool
    default     = true
}

// Bastion Host
variable "bastion_instance_type" {
    description = "The instance type for the bastion host."
    type        = string
    default     = "t3.micro"
}

variable "app_instance_type" {
    description = "The instance type for the application server."
    type        = string
    default     = "t3.micro"
}