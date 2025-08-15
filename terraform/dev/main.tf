locals{
project_id = "dev-posigen"
region     = "us-central1"
cloudrun_job_name = "dev-fleet-ingestion"
}

provider "google" {
  project     = local.project_id
  region      = local.region
}

resource "google_service_account" "cloud_run_job_sa" {
  account_id   = "fleet-job-sa"
  display_name = "Terraform Managed Service Account"
  description  = "Service account to access secret from cloud run."
  project      = "dev-posigen"
}

resource "google_service_account" "cloud_composer_service_account" {
  account_id   = "fleet-ingestion-test-sa"
  display_name = "Terraform Managed Service Account"
  description  = "Service account to access secret and run cloud run via composer."
  project      = "dev-posigen"
}

resource "google_project_iam_member" "job_sa_secret_access" {
  project = "dev-posigen"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_job_sa.email}"
}

resource "google_project_iam_member" "composer_sa_secret_accessor" {
  project = "dev-posigen"
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_composer_service_account.email}"
}

resource "google_project_iam_member" "composer_sa_cloud_run_access" {
  project = "dev-posigen"
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.cloud_composer_service_account.email}"
}

resource "google_cloud_run_v2_job" "default" {
  name     = local.cloudrun_job_name
  location = local.region
  deletion_protection = false

  template {
    template {
      service account = google_service_account.cloud_run_job_sa.email

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
    max_retries    = 0
    timeout        = "86400s"
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
  depends_on = [
    google_project_iam_member.job_sa_secret_access
  ]
}
