resource "google_compute_instance_group_manager" "instance_group" {
  name               = var.name_gruop
  base_instance_name = var.base_instance_name
  zone               = var.zone


  version {
    instance_template = google_compute_instance_template.default.id
  }

  named_port {
    name = var.named_port_name
    port = var.named_port
  }
  target_size = var.target_size

}

resource "google_compute_autoscaler" "default" {
  provider = google-beta

  name   = var.autoscaler_name
  zone   = var.zone
  target = google_compute_instance_group_manager.instance_group.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    load_balancing_utilization {
      target = 0.8
    }
  }
}



resource "google_compute_instance_template" "default" {
  name        = var.name_template
  description = var.description

  instance_description = var.instance_description
  machine_type         = var.machine_type
  can_ip_forward       = false
  tags                 = var.tags

  // Create a new boot disk from an image
  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true

  }
  //metadata_startup_script = file(var.startup_script)
  metadata_startup_script = var.startup_script


  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
    access_config {

    }
  }

  dynamic "service_account" {
    for_each = [var.service_account]
    content {
      email  = lookup(service_account.value, "email", null)
      scopes = lookup(service_account.value, "scopes", null)
    }
  }
}
