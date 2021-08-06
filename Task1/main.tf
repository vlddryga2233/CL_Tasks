provider "google" {
  credentials = var.credentials
  region      = var.region
  zone        = var.zone
  project     = var.project
}

provider "google-beta" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}


resource "google_service_account" "cloud_storage" {
  account_id   = "storage-viewer-service-account"
  display_name = "View and download content from bucket"
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = "tomcat-backend-32"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_storage.email}"
}


resource "google_compute_network" "network" {
  name = "my-vpc"
}

resource "google_compute_firewall" "default" {
  name    = "my-firewall"
  network = google_compute_network.network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000", "22"]
  }



  target_tags = ["tomcat"]
}

resource "google_compute_instance_template" "template" {

  name           = "my-template"
  machine_type   = "n1-standard-1"
  can_ip_forward = false

  tags = ["tomcat", "http-server"]

  metadata_startup_script = "sudo apt update -y; sudo apt install tomcat9 -y; sudo gsutil cp gs://tomcat-backend-32/sample.war /var/lib/tomcat9/webapps/sample.war"

  disk {
    source_image = "ubuntu-2004-lts"
  }
  network_interface {
    network = google_compute_network.network.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = google_service_account.cloud_storage.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "template2" {

  name           = "my-template-2"
  machine_type   = "n1-standard-1"
  can_ip_forward = false

  tags = ["tomcat", "http-server"]

  metadata_startup_script = "sudo apt update -y; sudo apt install nginx -y; sudo gsutil cp gs://tomcat-backend-32/default /ect/nginx/sites-available/default; sudo service nginx restart"

  disk {
    source_image = "ubuntu-2004-lts"
  }
  network_interface {
    network = google_compute_network.network.id
    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email  = google_service_account.cloud_storage.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_group_manager" "appserver" {
  name = "tomcat-backend"

  base_instance_name = "tomcat"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.template.id
  }

  named_port {
    name = "http"
    port = 8080
  }

  target_size = 2
}

resource "google_compute_instance_group_manager" "appserver2" {
  name = "nginx-backend"

  base_instance_name = "nginx"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.template2.id
  }
  named_port {
    name = "http"
    port = 80
  }

  target_size = 2
}
