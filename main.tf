# KMS resources
resource "random_id" "keyring" {
  byte_length = 4
}

resource "google_kms_key_ring" "key_ring" {
  name     = "${var.kms_keyring}-${random_id.keyring.hex}"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "key" {
  name            = var.tls_cert_name
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "604800s"

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = upper(var.kms_protection_level)
  }
}

# Certificate resources
resource "tls_private_key" "root_ca_key" {

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "root_ca_cert" {

  key_algorithm   = tls_private_key.root_ca_key.algorithm
  private_key_pem = tls_private_key.root_ca_key.private_key_pem

  subject {
    common_name         = var.tls_ca_subject.common_name
    country             = var.tls_ca_subject.country
    locality            = var.tls_ca_subject.locality
    organization        = var.tls_ca_subject.organization
    organizational_unit = var.tls_ca_subject.organizational_unit
    postal_code         = var.tls_ca_subject.postal_code
    province            = var.tls_ca_subject.province
    street_address      = var.tls_ca_subject.street_address
  }

  validity_period_hours = 26280
  early_renewal_hours   = 8760
  is_ca_certificate     = true

  allowed_uses = ["cert_signing"]
}

resource "tls_private_key" "private_key" {

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "csr" {

  key_algorithm   = tls_private_key.private_key.algorithm
  private_key_pem = tls_private_key.private_key.private_key_pem

  dns_names = var.tls_dns_names

  ip_addresses = var.ip_addresses

  subject {
    common_name         = var.tls_cn
    organization        = var.tls_ca_subject["organization"]
    organizational_unit = var.tls_ou
  }
}

resource "tls_locally_signed_cert" "cert" {

  cert_request_pem   = tls_cert_request.csr.cert_request_pem
  ca_key_algorithm   = tls_private_key.root_ca_key.algorithm
  ca_private_key_pem = tls_private_key.root_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca_cert.cert_pem

  validity_period_hours = 17520
  early_renewal_hours   = 8760

  allowed_uses = ["server_auth"]
}

# Encrypting the key with KMS
resource "google_kms_secret_ciphertext" "tls-key-encrypted" {
  crypto_key = google_kms_crypto_key.key.self_link
  plaintext  = tls_private_key.private_key.private_key_pem
}

resource "google_storage_bucket_object" "private-key" {
  name    = "${var.tls_cert_name}.enc"
  content = google_kms_secret_ciphertext.tls-key-encrypted.ciphertext
  bucket  = google_storage_bucket.tls.name

  lifecycle {
    ignore_changes = [
      content,
    ]
  }
}

# Creating GCS Bucket
resource "google_storage_bucket" "tls" {
  project       = var.project_id
  name          = var.tls_bucket
  location      = "EU"
  force_destroy = true
}

# Storing key and certificate material in a GCS Bucket
resource "google_storage_bucket_object" "server-cert" {
  name    = "${var.tls_cert_name}.crt"
  content = tls_locally_signed_cert.cert.cert_pem
  bucket  = google_storage_bucket.tls.name
}

resource "google_storage_bucket_object" "ca-cert" {

  name    = "${var.tls_cert_name}-ca.crt"
  content = tls_self_signed_cert.root_ca_cert.cert_pem
  bucket  = google_storage_bucket.tls.name
}

# Assign IAM permissions to access GCS Bucket
resource "google_storage_bucket_iam_member" "member" {
  for_each = toset(var.service_account_storage_bucket_iam_roles)
  bucket   = var.tls_bucket
  role     = each.key
  member   = "serviceAccount:${var.service_account_email}"
}

resource "google_storage_bucket_iam_member" "tls-bucket-iam" {

  bucket = google_storage_bucket.tls.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.service_account_email}"
}

# Assign IAM permissions to access KMS
resource "google_kms_crypto_key_iam_member" "ck-iam" {
  crypto_key_id = google_kms_crypto_key.key.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${var.service_account_email}"
}

resource "google_kms_crypto_key_iam_member" "tls-ck-iam" {

  crypto_key_id = google_kms_crypto_key.key.id
  role          = "roles/cloudkms.cryptoKeyDecrypter"
  member        = "serviceAccount:${var.service_account_email}"
}

