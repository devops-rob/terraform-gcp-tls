# Self-signed TLS cetificates stored in GCS Bucket

This module creates a [Certificate Authority](https://www.ssl.com/faqs/what-is-a-certificate-authority/), a [self-signed certificate](https://sectigostore.com/page/what-is-a-self-signed-certificate/) signed by the Certificate Authority and stores all certificates and keys in a GCS Bucket. All keys are encrypted using Google KMS before they are stored in the GCS Bucket.

This is useful for the deployment of systems in GCP that may require TLS when bootstrapping the system components. Access to the resulting certificate and key material is based on [GCP's Identity and Access Management domain model.](https://cloud.google.com/iam) A Service account will need to be created and then this module can assign the correct access rights to that service account using IAM Roles.

## Usage

```hcl
resource "google_service_account" "test" {
  account_id = "test-account"
}

resource "google_compute_address" "test" {
  name         = "test-ip"
  address_type = "EXTERNAL"
}

module "tls_cert" {
  source = "../"

  project_id            = var.project_id
  region                = var.project_region
  service_account_email = google_service_account.test.email
  tls_bucket            = "test-tls-bucket"
  tls_cert_name         = "devopsrob"

  ip_addresses = [
    google_compute_address.test.address,
    "127.0.0.1",
  ]

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
