variable "name_gruop" {
  description = "Name of instance group"
  default     = "instance_group"
}

variable "base_instance_name" {
  description = "Name of each instances"
  default     = "instance-from-template"
}

variable "zone" {
  default = ""
}

variable "named_port_name" {
  description = "Name of port"
  default     = "http"
}

variable "named_port" {
  description = "Port number"
  default     = "80"
}

variable "target_size" {
  default = "2"
}

variable "cooldown_period" {
  description = "Time when to check instances"
  default     = "60"
}

variable "name_template" {
  description = "The name of instance template"
  default     = "Instance-template"
}

variable "description" {
  description = "Description of description"
  default     = "Default instance tamplate"
}

variable "instance_description" {
  description = "Description for each instance"
  default     = "Default instance description"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  default     = "n1-standard-1"
}

variable "tags" {
  description = "Tags to attach firewall rules to instances"
  default     = []
}

variable "source_image" {
  description = "Source image for instance"
  default     = "ubuntu-2004-lts"
}

variable "startup_script" {
  description = "User startup script to run when instances spin up"
  default     = ""
}
variable "autoscaler_name" {
  default = ""
}
variable "max_replicas" {
  default = ""
}
variable "min_replicas" {
  default = ""
}
variable "network" {
  description = "VPC to connect instances"
  default     = "default"
}
variable "subnetwork" {
  default = ""
}


variable "service_account" {
  type = object({
    email  = string
    scopes = set(string)
  })
  description = "Service account to attach to the instance."
}

variable "id" {
  default = ""
}
