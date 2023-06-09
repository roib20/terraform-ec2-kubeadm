provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Terraform   = "true"
      provisioner = "Terraform"
      Owner       = "roi.bandel@develeap.com"
      Creator     = "roi.bandel@develeap.com"
      Email       = "roi.bandel@develeap.com"
      Objective   = "Develeap Hub"
      Expiration  = "20231230"
    }
  }
}
