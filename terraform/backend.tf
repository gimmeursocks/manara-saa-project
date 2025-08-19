terraform {
  backend "s3" {
    bucket       = "manara-saa-terraform-state-bucket"
    key          = "terraform/prod/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}