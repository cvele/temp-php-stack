terraform {
  backend "s3" {
    bucket = "app-terraform-state"
    key    = "app/app-production.tfstate"
    region = "eu-central-1"
  }
}
