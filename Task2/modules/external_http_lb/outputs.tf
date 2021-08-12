output "ip_name" {
  description = "Tags that will be associated with instance(s)"
  value       = google_compute_global_address.lb-ipv4-1.address
}
