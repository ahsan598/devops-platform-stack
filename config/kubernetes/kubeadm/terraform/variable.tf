variable "region" {
  default = "us-east-1"
}

variable "ami" {
  description = "Ubuntu 24.04 LTS AMI ID"
  default     = "ami-0ecb62995f68bb549"
}

variable "instance_type" {
  description = "Instance type for Master and Worker nodes (t3.medium recommended for k8s)"
  default     = "t3.medium"
}

variable "key_name" {
  description = "Your AWS EC2 Key Pair name for SSH access"
  default     = "your-key-name"
}
