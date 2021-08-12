provider "google" {
  credentials = var.credentials
  region      = var.region
  zone        = var.zone
  project     = var.project
}
provider "google-beta" {
  credentials = var.credentials
  region      = var.region
  zone        = var.zone
  project     = var.project
}


# Service account for VM instances
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"

}

# Policy to allow connect to the bucket
resource "google_storage_bucket_iam_member" "member" {
  depends_on = [module.bucket.name]
  bucket     = "backend-storage-44"
  role       = "roles/storage.objectViewer"
  member     = "serviceAccount:${google_service_account.default.email}"
}

# Policy to allow connect to the BiqQuery
resource "google_bigquery_dataset_iam_member" "editor" {
  depends_on = [module.bucket.name]
  dataset_id = "fluentd"
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.default.email}"
}

# Custom network
resource "google_compute_network" "default" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Custom subnet for region
resource "google_compute_subnetwork" "default" {
  name          = "backend-subnet"
  ip_cidr_range = "10.1.2.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

# module to create bucket with config files and bucket for public image.
module "bucket" {
  source       = "./modules/bucket"
  storage_name = "backend-storage-44"
  network      = google_compute_network.default.id
}

# Module to create MIG based on template
module "nginx_group" {
  source               = "./modules/instance_group"
  depends_on           = [module.bucket.storage_name]
  name_template        = "nginx-template"
  description          = "Template for creation instances with installed Nginx"
  instance_description = "Nginx web-server set as reverse proxy"
  source_image         = "debian-cloud/debian-10"
  tags                 = ["allow-health-check", "nginx", "http-server"]
  startup_script       = file("files\\file.sh")
  service_account = ({
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  })
  name_gruop      = "nginx-group"
  autoscaler_name = "ng-scale"
  max_replicas    = 5
  min_replicas    = 1

  base_instance_name = "nginx"
  named_port_name    = "http"
  named_port         = "80"
  network            = google_compute_network.default.id
  subnetwork         = google_compute_subnetwork.default.id
}

# Module to create MIG based on template
module "tomcat_group" {
  source               = "./modules/instance_group"
  depends_on           = [module.bucket.storage_name]
  name_template        = "tomcat-template"
  description          = "Template for creation instances with installed Tomcat"
  instance_description = "Tomcat web-server"
  source_image         = "ubuntu-2004-lts"
  # source_image = "centos-8"
  tags           = ["allow-health-check", "tomcat", "http-server"]
  startup_script = file("files\\tomcat.sh")
  # startup_script = file("files\\tomcat-c.sh")
  service_account = ({
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  })
  name_gruop         = "tomcat-group"
  autoscaler_name    = "tom-scale"
  max_replicas       = 5
  min_replicas       = 1
  base_instance_name = "tomcat"
  named_port_name    = "http"
  named_port         = "8080"
  network            = google_compute_network.default.id
  subnetwork         = google_compute_subnetwork.default.id
}

# Data to connect LB and MIG
data "google_compute_instance_group" "default" {
  name = "nginx-group"
}
# Data to connect LB and MIG
data "google_compute_instance_group" "default2" {
  name = "tomcat-group"
}

# External http load balancer
module "nginx-lb" {
  source  = "./modules/external_http_lb"
  network = google_compute_network.default.id

  depends_on             = [module.nginx_group]
  backend_instance_group = data.google_compute_instance_group.default.id

}

# Internal http load balancer
module "tomcat-lb" {
  source                  = "./modules/internal_http_lb"
  network                 = google_compute_network.default.id
  subnet_proxy_network    = google_compute_network.default.id
  forwarding_rule_network = google_compute_network.default.id
  subnetwork              = google_compute_subnetwork.default.id

  depends_on             = [module.tomcat_group]
  backend_instance_group = data.google_compute_instance_group.default.id
}
