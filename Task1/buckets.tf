provider "google" {
  credentials = var.credentials
  region      = var.region
  zone        = var.zone
  project     = var.project
}


resource "google_storage_bucket" "bucket" {
  name          = "tomcat-backend-32"
  force_destroy = true
  location      = "EU"
}

resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.bucket2.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_storage_bucket" "bucket2" {
  name                        = "image-website"
  force_destroy               = true
  location                    = "EU"
  uniform_bucket_level_access = false




}
