terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(abspath(var.credentials_file))
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  credentials = file(abspath(var.credentials_file))
}

module "bigquery" {
  source = "./modules/bigquery"

  project_id      = var.project_id
  credentials_file = var.credentials_file
  config_file     = var.config_file
  dataset_id      = var.dataset_id
  location        = var.region
} 