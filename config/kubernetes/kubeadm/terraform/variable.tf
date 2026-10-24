variable "region" {
  description = "AWS region for Kubernetes cluster"
  type        = string
  default     = "us-east-1"
}

variable "availability_zone" {
  description = "Availability zone containing a default subnet"
  type        = string
  default     = "us-east-1a"
}

variable "ami" {
  description = "AMI ID for Kubernetes EC2 instances (Ubuntu 24.04 LTS)"
  type        = string
  default     = "ami-0ecb62995f68bb549"
}

variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "your-key-name"
}
