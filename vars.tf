variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "availability_zone" {
  type    = string
  default = "eu-west-2b"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ebs_volume_size_gb" {
  type    = number
  default = 8
}

variable "service" {
  type    = string
  default = "jupyter"
}
