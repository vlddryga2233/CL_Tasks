variable "firewal_allow_helth_check_name" {
  description = "The name of firewall for health check"
  default     = "fw-allow-health-check"
}
variable "network" {
  description = "The name of network"
  default     = "default"
}
variable "ip_name" {
  description = "The name of end IP"
  default     = "lb-ipv4-1"
}
variable "http_health_check_name" {
  description = "The name of health_check"
  default     = "http-basic-check"
}
variable "health_check_port" {
  description = "Port number to check heatlh"
  default     = "80"
}
variable "backend_name" {
  description = "Name of backend service"
  default     = "web-backend-service"
}
variable "backend_instance_group" {
  description = "Instance group for backend service"
  default     = ""
}
variable "url_map_name" {
  description = "Name for url map"
  default     = "web-map-http"
}
variable "http_proxy_name" {
  description = "Name for http proxy"
  default     = "http-lb-proxy"
}
variable "forwarding_rule_name" {
  description = "Name for forwarding rule"
  default     = "http-content-rule"
}
variable "port_range" {
  description = "Port for frontand lb"
  default     = "80"
}
