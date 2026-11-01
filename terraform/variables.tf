variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "location" {
  type    = string
  default = "westus2"
}

variable "student_id" {
  type        = string
  default     = "yeewi"
  description = "Lowercase letters/numbers only"
}

variable "acr_unique_suffix" {
  type        = string
  description = "Unique lowercase letters/numbers for global ACR name"
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "node_count" {
  type    = number
  default = 1
}