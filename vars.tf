# Project variables
variable "project_id" {
  type        = string
  description = "ID of the project in which to create resources and add IAM bindings."
}

variable "region" {
  type        = string
  default     = "europe-west1"
  description = "Region in which to create resources."
}

# KMS variables
variable "kms_keyring" {
  type        = string
  default     = "tls"
  description = "Name of the Cloud KMS KeyRing for asset encryption. Terraform will create this keyring."

}

variable "kms_protection_level" {
  type    = string
  default = "software"

  description = "The protection level to use for the KMS crypto key."
}

# GCS Bucket resources
variable "bucket_location" {
  type        = string
  default     = "EU"
  description = "Geograpgical region in which the GCS Bucket should reside."
}

variable "tls_bucket" {
  type        = string
  description = "GCS Bucket to store resulting certificates and keys. Terraform will create this Bucket."
}

# TLS variables 
variable "tls_cert_name" {
  type        = string
  description = "Name for the self-signed TLS certificate."
}

variable "tls_ou" {
  description = "The TLS Organizational Unit for the TLS certificate"
  default     = "HashiCorp Developer Advocates"
}

variable "tls_ca_subject" {
  description = "The `subject` block for the root CA certificate."
  type = object({
    common_name         = string,
    organization        = string,
    organizational_unit = string,
    street_address      = list(string),
    locality            = string,
    province            = string,
    country             = string,
    postal_code         = string,
  })

  default = {
    common_name         = "Example Inc. Root"
    organization        = "Example, Inc"
    organizational_unit = "Department of Certificate Authority"
    street_address      = ["123 Example Street"]
    locality            = "The Intranet"
    province            = "CA"
    country             = "US"
    postal_code         = "95559-1227"
  }
}

variable "tls_dns_names" {
  description = "List of DNS names added to the self-signed certificate. E.g vault.example.net"
  type        = list(string)
  default     = []
}

variable "ip_addresses" {
  type    = list(string)
  default = []
}

variable "tls_cn" {
  description = "The TLS Common Name for the TLS certificates"
  default     = "certificate.example.net"
}

# IAM variables
variable "service_account_email" {
  type = string
}

variable "service_account_storage_bucket_iam_roles" {
  type = list(string)

  default = [
    "roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]

  description = "List of IAM roles for the service account to have on the storage bucket."
}
