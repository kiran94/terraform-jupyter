variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources into"
  default     = "eu-west-2"
}
variable "availability_zone" {
  type        = string
  description = "The AWS Availability Zone to deploy resources into"
  default     = "eu-west-2b"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use for the Jupyter server"
  default     = "t2.micro"
}

variable "ebs_volume_size_gb" {
  type        = number
  description = "The size of the EBS volume in GB"
  default     = 8
}

variable "service" {
  type        = string
  description = "The name of the service to deploy. This is a arbitrary label."
  default     = "jupyter"
}
