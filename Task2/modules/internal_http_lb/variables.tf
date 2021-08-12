variable "firewal_allow_helth_check_name" {
  description = "The name of firewall for health check"
  default     = "ilb-allow-health-check"
}
variable "network" {
  description = "The name of network"
  default     = "default"
}
variable "forwarding_rule_network" {
  default = ""
}

variable "subnet_proxy_network" {
  default = ""
}
variable "subnetwork" {
  default = ""
}
variable "http_health_check_name" {
  description = "The name of health_check"
  default     = "ilb-basic-check"
}
variable "health_check_port" {
  description = "Port number to check heatlh"
  default     = "8080"
}
variable "backend_name" {
  description = "Name of backend service"
  default     = "lib-backend-service"
}
variable "backend_instance_group" {
  description = "Instance group for backend service"
  default     = ""
}

variable "url_map_name" {
  description = "Name for url map"
  default     = "url-map"
}
variable "http_proxy_name" {
  description = "Name for http proxy"
  default     = "http-ilb-proxy"
}
variable "forwarding_rule_name" {
  description = "Name for forwarding rule"
  default     = "http-content-rule"
}
variable "port_range" {
  description = "Port for frontand lb"
  default     = "8080"
}

variable "region_subnet" {
  default = "us-central1"
}

variable "region" {
  default = "us-central1"
}

variable "project" {
  default = ""
}

variable "group_name" {
  default = ""
}

variable "zone" {
  default = ""
}
