variable "env"{}
variable "vpc_security_group_ids" {}
variable "db_instances"{}
variable "zone_id" {}
variable "vault_token" {
  type = string
}

variable "eks" {}