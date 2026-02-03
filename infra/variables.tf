variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
}

# Variables for peering (add to variables.tf)
variable "peer_vpc_peering_connection_id" {
  description = "The ID of the VPC peering connection to accept (provided by requester team)"
  type        = string
  default     = null
}

variable "peer_vpc_cidr" {
  description = "The CIDR block of the peer VPC"
  type        = string
  default     = null
}
