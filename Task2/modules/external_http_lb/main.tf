resource "google_compute_firewall" "fw-allow-health-check" {
  name      = var.firewal_allow_helth_check_name
  network   = var.network
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-health-check"]
}

resource "google_compute_global_address" "lb-ipv4-1" {
  name = var.ip_name
}

resource "google_compute_http_health_check" "http-basic-check" {
  name         = var.http_health_check_name
  request_path = "/"
  port         = var.health_check_port

  timeout_sec        = 1
  check_interval_sec = 1
}
data "google_compute_instance_group" "default" {
  name = "nginx-group"
}
resource "google_compute_backend_service" "web-backend-service" {
  provider      = "google-beta"
  name          = var.backend_name
  health_checks = [google_compute_http_health_check.http-basic-check.id]
  protocol      = "HTTP"
  port_name     = "http"
  depends_on    = [data.google_compute_instance_group.default]

  backend {
    group           = data.google_compute_instance_group.default.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 0.8
    #group = var.backend_instance_group
  }
}

resource "google_compute_url_map" "web-map-http" {
  name            = var.url_map_name
  default_service = google_compute_backend_service.web-backend-service.id
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = var.http_proxy_name
  url_map = google_compute_url_map.web-map-http.id
}

resource "google_compute_global_forwarding_rule" "http-content-rule" {
  name       = var.forwarding_rule_name
  target     = google_compute_target_http_proxy.http-lb-proxy.id
  port_range = var.port_range
  ip_address = google_compute_global_address.lb-ipv4-1.id
}
