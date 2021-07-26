# Updated Certficate Authority example

This example shows how to specify the Certificate Authority subject in the module.

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

  tls_ca_subject = {
    common_name         = "HashiCorp Inc. Root"
    organization        = "HashiCorp, Inc"
    organizational_unit = "Department of Certificate Authority"
    street_address      = ["123 Hashi Street"]
    locality            = "The Internet"
    province            = "London"
    country             = "UK"
    postal_code         = "SW1 2EG"
  }

}
```
