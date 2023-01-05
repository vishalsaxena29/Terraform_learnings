#This is the provider whose resources I am going to use.
provider "aws"{
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}