resource "google_compute_firewall" "fw-allow-health-check" {
  name      = var.firewal_allow_helth_check_name
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

data "google_compute_instance_group" "default" {
  name = "tomcat-group"
}
resource "google_compute_region_health_check" "default" {
  provider = google-beta

  region = var.region
  name   = "website-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_region_backend_service" "ilb-backend-service" {
  provider                        = "google-beta"
  name                            = var.backend_name
  region                          = var.region
  health_checks                   = [google_compute_region_health_check.default.id]
  depends_on                      = [data.google_compute_instance_group.default]
  load_balancing_scheme           = "INTERNAL_MANAGED"
  connection_draining_timeout_sec = 120

  protocol  = "HTTP"
  port_name = "http"


  backend {
    group           = data.google_compute_instance_group.default.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 0.8
    //group = var.backend_instance_group
  }
}

resource "google_compute_region_url_map" "url-map" {
  name            = var.url_map_name
  default_service = google_compute_region_backend_service.ilb-backend-service.id
  region          = var.region
}

resource "google_compute_region_target_http_proxy" "http-ilb-proxy" {
  name    = var.http_proxy_name
  url_map = google_compute_region_url_map.url-map.id
  region  = var.region
}
resource "google_compute_forwarding_rule" "default" {
  provider   = google-beta
  depends_on = [google_compute_subnetwork.proxy]
  name       = var.forwarding_rule_name
  region     = var.region
  subnetwork = var.subnetwork

  ip_address            = "10.1.2.99"
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = var.port_range
  target                = google_compute_region_target_http_proxy.http-ilb-proxy.id
  network               = var.forwarding_rule_network
  network_tier          = "PREMIUM"
}

resource "google_compute_subnetwork" "proxy" {
  provider      = google-beta
  name          = "website-net-proxy"
  ip_cidr_range = "10.129.0.0/23"
  region        = var.region_subnet
  network       = var.subnet_proxy_network
  purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
  role          = "ACTIVE"
}

resource "google_compute_firewall" "default" {
  name    = "fw-allow-proxy"
  network = var.network
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  source_ranges = ["10.129.0.0/23"]

  target_tags = ["tomcat"]

}
