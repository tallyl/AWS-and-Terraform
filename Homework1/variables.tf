variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

variable "profile" {
  default = "opsschool"
}

variable "region" {
  default = "eu-west-1"
}