# Static external IP address
resource "google_compute_address" "tf-vm-ip" {
  name = "ipv4-address-tf-vm"
}

resource "google_compute_instance" "tf-vm" {
  name         = "tf-vm"
  zone         = "us-central1-c"
  machine_type = "n1-standard-2"

  # Required to change machine_type on a running instance (it is stopped, resized, restarted)
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  # Add SSH access to the Compute Engine instance
  metadata = {
    ssh-keys = "${var.gcp-username}:${file("~/.ssh/id_rsa.pub")}"
  }

  # Add http tag to the instance to identify it in the firewall rule
  tags = ["http"]

  # Startup script
  metadata_startup_script = file("setup-docker.sh")

  network_interface {
    network    = var.gcp-network
    subnetwork = var.gcp-network

    access_config {
      nat_ip = google_compute_address.tf-vm-ip.address
    }
  }
}

# Extra 1GB SSD volume
resource "google_compute_disk" "tf-disk" {
  name = "tf-disk"
  zone = "us-central1-c"
  type = "pd-ssd"
  size = 1
}

# Attach the volume to the instance
resource "google_compute_attached_disk" "attached-tf-disk" {
  disk     = google_compute_disk.tf-disk.id
  instance = google_compute_instance.tf-vm.id
}

output "tf-vm-ip" {
  value      = google_compute_address.tf-vm-ip.address
  depends_on = [google_compute_instance.tf-vm]
}

output "tf-vm-internal-ip" {
  value      = google_compute_instance.tf-vm.network_interface.0.network_ip
  depends_on = [google_compute_instance.tf-vm]
}

output "tf-vm-ephemeral-ip" {
  value      = google_compute_instance.tf-vm.network_interface.0.access_config.0.nat_ip
  depends_on = [google_compute_instance.tf-vm]
}
