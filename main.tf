# ++++++++++++++++++++++++++++++++ 
# +++++ PROJECT BOILER PLATE +++++
# ++++++++++++++++++++++++++++++++ 

locals {
  project_name = "${var.project_id}-${terraform.workspace == "default" ? "dev" : terraform.workspace}"
  
  # Name of the storage bucket to hold tf state
  bucket_name = "${local.project_name}-tfstate"
  timestamp         = formatdate("YYMMDDhhmmss", timestamp())
}

# Project factory
# https://registry.terraform.io/modules/terraform-google-modules/project-factory/google/latest
module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 10.1"

  org_id          = var.org_id
  billing_account = var.billing_account

  folder_id = var.folder_id

  name              = local.project_name
  
  random_project_id = false
  create_project_sa = "false"
  auto_create_network = false

  # Set remote state bucket
  bucket_location = var.bucket_location
  bucket_name     = local.bucket_name
  bucket_project  = local.project_name

  default_service_account = "disable"

  # Enable APIs
  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

# Create Terraform service account
module "service-accounts" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.0.2"
  project_id = module.project-factory.project_id
  names      = [var.tf_sa_name]

  depends_on = [module.project-factory]
}

resource "google_storage_bucket_iam_member" "s_account_storage_admin_on_project_bucket" {
  bucket = local.bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.service-accounts.email}"

  depends_on = [module.service-accounts]
}

resource "null_resource" "writebackend" {
  provisioner "local-exec" {
      command = "sed -i 's+bucket.*+bucket = ${local.bucket_name}+g' eval/backend.hcl"
  }
}

