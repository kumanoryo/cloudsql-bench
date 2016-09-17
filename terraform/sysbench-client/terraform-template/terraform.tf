variable "credentials" {}
variable "project_id" {}
variable "region" {}
variable "machine_type" {}
variable "network_name" {}
variable "zone" {}
variable "source_image" {}
variable "bucket_name" {}
variable "target_size" {}


provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_instance_template" "sysbench-client" {
    name = "template-sysbench-client"
    machine_type = "${var.machine_type}"
    tags = ["sysbench-client"]

    scheduling {
      automatic_restart = true
      on_host_maintenance = "MIGRATE"
    }

    disk {
        source_image = "${var.source_image}"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = "${var.network_name}"
        access_config {}
    }

    service_account {
        scopes = [ 
          "https://www.googleapis.com/auth/devstorage.read_write"
          ,"https://www.googleapis.com/auth/compute"
          ,"https://www.googleapis.com/auth/sqlservice.admin"
        ]
    }

    metadata {
      startup-script-url="gs://${var.bucket_name}/startup-script/start.sh"
    }
}

resource "google_compute_instance_group_manager" "sysbench-client" {
    name = "instance-group-sysbench-client"
    instance_template = "${google_compute_instance_template.sysbench-client.self_link}"
    base_instance_name = "sysbench-client"
    zone = "${var.zone}"
    target_size = "${var.target_size}" 
}
