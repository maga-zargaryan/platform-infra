terraform {
  backend "s3" {
    bucket       = "tfstate-286325277771-eu-west-1"
    use_lockfile = true
  }
}
