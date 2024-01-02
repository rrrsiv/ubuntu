
#### RDS Details ###
variable "instance_class" {}
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "engine" {}
variable "engine_version" {}
variable "db_name" {}
variable "name" {}
variable "username" {}
variable "pass" {}
variable "family" {}
variable "major_engine_version" {}
variable "backup_retention_period" {}
variable "port" {}
variable "parameter_group_name" {}
variable "region" {}
variable "environment" {}
locals {
  name   = var.db_name
  region = var.region
  tags = {
  }
}
#variable "secrets_name" {}
variable "master_vpc_id" {}
variable "replica_vpc_id" {}

