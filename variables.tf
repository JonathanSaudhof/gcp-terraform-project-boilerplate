variable "project_id" {}

variable "project_region" {
  description = "The region  account to attach to the project"
}

variable "org_id" {
  description = "The organization id"
  type        = string
}

variable "billing_account" {
  description = "The billing account to attach to the project"
  type        = string
}

variable "folder_id" {
  type        = string
  description = "The if of the folder to contain the project"
  default     = ""
}

variable "budget_amount" {
  type        = number
  description = "The amount to use for a budget alert"
  default     = 5
}

variable "bucket_location" {
  type        = string
  description = "Where to store the bucket"
}

variable "tf_sa_name" {
  type        = string
  description = "The name of the service account to be used with terraform"
  default     = "terraform-sa"
}

# variable "first_run" {
#   type = bool
#   description = "Indicates if it is a first run"
#   default = false
# }