# Minimal exmample

This example shows a minimal way of using the module with all of the default variavle values.

```hcl
terraform {
  required_version = ">= 0.12.31"
  required_providers {
    google = {
      version = "~> 3.69"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.project_region
}

data "google_project" "project" {}

variable "project_id" {}
variable "project_region" {}

resource "google_service_account" "test" {
  account_id = "test-account"
}

module "tls_cert" {
  source = "devops-rob/tls/gcp"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_service_account.test.email
  tls_bucket            = "test-tls-bucket"
  tls_cert_name         = "devopsrob"
}
```
