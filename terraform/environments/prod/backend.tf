terraform {
  backend "s3" {
    bucket       = "tfstate-286325277771-eu-west-1"
    key          = "platform/prod/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
  }
}
