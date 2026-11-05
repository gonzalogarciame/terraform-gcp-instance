terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.5.0"
    }
  }
}

provider "google" {
  credentials = file("lab-6-513107-4cefed3fabbe.json")

  project = var.gcp-project
  region  = "us-central1"
  zone    = "us-central1-c"
}
