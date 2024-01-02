
////RDS Instance////
// RDS Module Version - version = "5.4.2" ///

instance_class        = "db.t2.small"
allocated_storage     = 5
max_allocated_storage = 10
engine               = "mysql"
username = "tsuhybris"
pass = "55ueJF3MYIb#"
db_name = "tsurds"
engine_version       = "8.0"
family               = "mysql8.0" # DB parameter group
parameter_group_name = "tsu-hybris-instance-mysql-rds"
name = "tsu-hybris-mysql-rds"
major_engine_version = "8.0"
backup_retention_period = 1
port     = 3306
region = "us-east-2"
environment = "test"
#secrets_name = "${secrets_name}"
master_vpc_id = "vpc-0fb8d6d27276355fe"
replica_vpc_id = "vpc-069312a38ca9a8482"