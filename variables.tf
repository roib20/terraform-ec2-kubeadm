variable "instance_name" {
  type        = string
  nullable    = true
}

variable "aws_region" {
  type        = string
  description = "aws_region"
  default     = "us-east-1"
  nullable    = false
}

variable "key_name" {
  type        = string
  description = "key_name"
  nullable    = false
  sensitive   = true
}

variable "my_ip" {
  type        = string
  description = "my_ip"
  nullable    = false
  sensitive   = true
}

variable "sg_name" {
  type        = string
  description = "security group name"
  nullable    = false
}

variable "instance_type" {
  type        = string
  description = "instance_type"
  default     = "t3a.nano"
  nullable    = false
}

variable "volume_type" {
  type        = string
  description = "volume_type"
  default     = "gp3"
  nullable    = false
}

variable "volume_size" {
  type        = number
  description = "volume_size"
  default     = 8
  nullable    = false
}
