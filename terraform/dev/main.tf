locals{
project_id = "dev-posigen"
region     = "us-central1"
}

provider "google" {
  project     = local.project_id
  region      = local.region
}

