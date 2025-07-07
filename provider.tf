provider "aws" {
  region = "us-east-1" # change if needed
}


provider "vault" {
  address = "http://vault.mikeydevops1.online:8200/"
  token = var.vault_token
}