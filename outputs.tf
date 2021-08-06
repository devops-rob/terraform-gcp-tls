output "self_signed_cert" {
  value     = tls_locally_signed_cert.cert.cert_pem
  sensitive = true
}

output "bucket_id" {
  value = google_storage_bucket.tls.id
}

output "key_id" {
  value = google_kms_crypto_key.key.id
}

output "key_ring_id" {
  value = google_kms_key_ring.key_ring.id
}

output "encrypted_private_key" {
  value = google_kms_secret_ciphertext.tls-key-encrypted.ciphertext
}

output "cert_filename" {
  value = google_storage_bucket_object.server-cert.name
}

output "key_filename" {
  value = google_storage_bucket_object.private-key.name
}

output "ca_filename" {
  value = google_storage_bucket_object.ca-cert.name
}
