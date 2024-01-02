provider "aws" {
  region = "us-east-2"
 }

provider "aws" {
  alias = "region1"
  region = "ap-south-1"
 }


module "db" {
 source = "terraform-aws-modules/rds/aws"
 version = "5.4.2"
 instance_class                 = var.instance_class 
 allocated_storage              = var.allocated_storage    
 max_allocated_storage          = var.max_allocated_storage 
 engine                         = var.engine                     
 engine_version                 = var.engine_version                          
 db_name                        = var.db_name                                   
 username                       = var.username    
 password                       = var.pass                                           
 #password                       = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]                                      
 family                         = var.family                  
 major_engine_version           = var.major_engine_version            
 multi_az                       = true
 publicly_accessible            = true
 backup_retention_period        = var.backup_retention_period
 vpc_security_group_ids         = [module.security_group.security_group_id]
 identifier                     = var.name
 port                           = var.port
 skip_final_snapshot            = true
 deletion_protection            = false
 create_db_subnet_group         = true
 enabled_cloudwatch_logs_exports = ["general"]
 subnet_ids                     = data.aws_subnet_ids.master_subnets.ids
 tags                           = local.tags
 parameter_group_name           = var.parameter_group_name
 create_random_password         = false
 apply_immediately              = true
 create_db_option_group         = false

 depends_on = [
  module.security_group
 ]

}

######################### Replica ############################

data "aws_caller_identity" "current" {}

module "kms" {
  source      = "terraform-aws-modules/kms/aws"
  version     = "~> 1.0"
  description = "KMS key for cross region replica DB"

  # Aliases
  aliases                 = [local.name]
  aliases_use_name_prefix = true

  key_owners = [data.aws_caller_identity.current.id]

  tags = local.tags

  providers = {
    aws = aws.region1
  }
}


module "replica" {
  source = "terraform-aws-modules/rds/aws"
  version = "5.4.2"

  providers = {
    aws = aws.region1
  }

  identifier = "${var.name}-rds-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = module.db.db_instance_arn
  create_random_password = false

  engine               = var.engine
  engine_version       = var.engine_version 
  family               = var.family
  major_engine_version = var.major_engine_version
  instance_class       = var.instance_class
  kms_key_id           = module.kms.key_arn

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  publicly_accessible   = true
  # Username and password should not be set for replicas
  username = null
  password = null
  port     = var.port
  create_db_subnet_group   = true
  multi_az               = false
  vpc_security_group_ids = [module.security_group_dr.security_group_id]

  maintenance_window              = "Tue:00:00-Tue:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  subnet_ids             = data.aws_subnet_ids.replica_subnets.ids
  # Specify a subnet group created in the replica region
 # db_subnet_group_name = data.aws_subnet_ids.replica_subnets.ids

  #tags = local.tags

  depends_on = [
    module.security_group_dr
  ]
}


data "aws_vpc" "dr" {
  id = var.master_vpc_id
}




data "aws_vpc" "replica" {
  id = var.replica_vpc_id
  provider = aws.region1
}


# data "aws_subnets" "sub_selected" {
#   tags = {
#   Tier = "private"
#   Environment = var.environment
#   }
# }

data "aws_subnet_ids" "master_subnets" {
  # tags = {
    
  #   Name = [ "Subnet-1, Subnet-2, Subnet-3" ]
  # }
  vpc_id = data.aws_vpc.dr.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.master_subnets.ids
  id       = each.value
}

data "aws_subnet_ids" "replica_subnets" {
  # tags = {
    
  #   Name = [ "Subnet-1, Subnet-2, Subnet-3" ]
  # }
  vpc_id = data.aws_vpc.replica.id
  provider = aws.region1
}

data "aws_subnet" "example1" {
  for_each = data.aws_subnet_ids.replica_subnets.ids
  id       = each.value
  provider = aws.region1
}


# output "aws_subnets" {

#   value = data.aws_subnets.sub_selected.ids
# }

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.master_subnets : s.cidr_block]
# }

# output "rsubnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.replica_subnets : s.cidr_block]
# }