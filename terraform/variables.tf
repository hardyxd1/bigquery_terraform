variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "credentials_file" {
  description = "Path to the service account credentials file"
  type        = string
}

variable "config_file" {
  description = "Path to the configuration JSON file"
  type        = string
}

variable "dataset_id" {
  description = "The BigQuery dataset ID"
  type        = string
  default     = "ecommerce_data"
} 