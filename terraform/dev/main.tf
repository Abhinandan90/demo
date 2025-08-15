locals{
project_id = "dev-posigen"
region     = "us-central1"
cloudrun_job_name = "dev-fleet-ingestion"
}

provider "google" {
  project     = local.project_id
  region      = local.region
}

resource "google_service_account" "my_service_account" {
  account_id   = "my-terraform-sa" # Unique ID for the service account
  display_name = "Terraform Managed Service Account"
  description  = "Service account managed by Terraform for GCP resources."
  project      = "your-gcp-project-id" # Replace with your GCP project ID
}

resource "google_cloud_run_v2_job" "default" {
  name     = local.cloudrun_job_name
  location = local.region
  deletion_protection = false

  template {
    template {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/job"
        resources {
          limits = {
            cpu    = "1"
            memory = "2Gi"
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}
