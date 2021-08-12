resource "google_storage_bucket" "default" {
  name          = var.storage_name
  location      = "EU"
  force_destroy = true

}

resource "google_storage_bucket_object" "picture" {
  depends_on = [google_storage_bucket.bucket2]
  name       = "picture.jpg"
  source     = "files\\picture.jpg"
  bucket     = "image-website"
}

resource "google_storage_bucket_object" "default" {
  depends_on = [google_storage_bucket.default]
  name       = "default"
  source     = "files\\default"
  bucket     = "backend-storage-44"
}
resource "google_storage_bucket_object" "agent" {
  depends_on = [google_storage_bucket.default]
  name       = "td-agent.conf"
  source     = "files\\td-agent.conf"
  bucket     = "backend-storage-44"
}


resource "google_compute_firewall" "default" {
  name    = "fw-allow-connection"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "1000-2000"]
  }

  target_tags = ["nginx", "tomcat"]

}


resource "google_storage_bucket_object" "sample" {
  depends_on = [google_storage_bucket.default]
  name       = "sample.war"
  source     = "files\\sample.war"
  bucket     = "backend-storage-44"
}


resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.bucket2.name
  role   = "READER"
  entity = "allUsers"

}
resource "google_storage_default_object_access_control" "public_rule" {
  bucket = google_storage_bucket.bucket2.id
  role   = "READER"
  entity = "allUsers"
}


resource "google_storage_bucket" "bucket2" {
  name                        = "image-website"
  force_destroy               = true
  location                    = "EU"
  uniform_bucket_level_access = false
}
