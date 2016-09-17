variable "credentials" {}
variable "project_id" {}
variable "region" {}
variable "bucket_name" {}
variable "network_name" {}

provider "google" {
  credentials = "${file("/tmp/application_default_credentials.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

data "terraform_remote_state" "default" {
    backend = "gcs"
    config {
        bucket = "${var.bucket_name}"
        path = "/opt/network/terraform.tfstate"
        project = "${var.project_id}"
    }
}

resource "template_file" "default" {
  template = "${greeting}"

  vars {
    greeting = "${data.terraform_remote_state.default.output.greeting}"
  }
}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = true
}
