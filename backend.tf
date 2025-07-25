terraform {
  backend "s3" {
    encrypt = true
    bucket  = "mytodoappbucketttt"
    key     = "jenkin-server/terraform.tfstate"
    region  = "us-east-2"
  }
}