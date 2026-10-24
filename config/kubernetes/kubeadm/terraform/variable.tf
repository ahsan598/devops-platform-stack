variable "region" {
  description = "AWS region for Kubernetes cluster"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone containing a default subnet"
  type        = string
}

variable "ami" {
  description = "AMI ID for Kubernetes EC2 instances (Ubuntu 24.04 LTS)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "my_public_ip" {
  description = "Your public IPv4 address in /32 CIDR notation"
  type        = string

  validation {
    condition = can(cidrnetmask(var.my_public_ip)) && endswith(var.my_public_ip, "/32")

    error_message = "Invalid CIDR notation for my_public_ip. Provide a valid IPv4 CIDR ending in /32, (e.g., 203.0.113.10/32)."
  }
}
