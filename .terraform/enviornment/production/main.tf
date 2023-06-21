locals {
  environment           = element(split("/", path.cwd), length(split("/", path.cwd)) - 1) # current directory
  cidr_block            = "10.0.0.0/16"
  public_a_subnet_cidr  = "10.0.0.0/24"
  public_b_subnet_cidr  = "10.0.1.0/24"
  nat_a_subnet_cidr     = "10.0.2.0/24"
  nat_b_subnet_cidr     = "10.0.3.0/24"
  private_a_subnet_cidr = "10.0.4.0/24"
  private_b_subnet_cidr = "10.0.5.0/24"

}
module "network" {
  source                = "../../modules/network"
  environment           = local.environment
  cidr_block            = local.cidr_block
  public_a_subnet_cidr  = local.public_a_subnet_cidr
  public_b_subnet_cidr  = local.public_b_subnet_cidr
  nat_a_subnet_cidr     = local.nat_a_subnet_cidr
  nat_b_subnet_cidr     = local.nat_b_subnet_cidr
  private_a_subnet_cidr = local.private_a_subnet_cidr
  private_b_subnet_cidr = local.private_b_subnet_cidr
}

module "route53" {
  source = "../../modules/route53"
}

module "database" {
  source           = "../../modules/database"
  environment      = local.environment
  primary_dns_zone = module.route53.primary_dns_zone
  main_vpc         = module.network.main_vpc
  subnet_nat_a     = module.network.subnet_nat_a
  subnet_nat_b     = module.network.subnet_nat_b
}

module "bastion" {
  source           = "../../modules/bastion"
  primary_dns_zone = module.route53.primary_dns_zone
  main_vpc         = module.network.main_vpc
  subnet_public_a  = module.network.subnet_public_a
}
module "ejabberd" {
  source                     = "../../modules/ejabberd"
  environment                = local.environment
  ejabberd_ec2_instance_type = "t4g.nano"
  primary_dns_zone           = module.route53.primary_dns_zone
  aws_lb_main                = module.network.aws_lb_main
  rds_credentials_secret     = module.database.rds_credentials_secret
  auth_provider_host         = "http://89.216.18.221:8080"
  main_vpc                   = module.network.main_vpc
  subnet_nat_a               = module.network.subnet_nat_a
  main_key_pair              = module.bastion.main_key_pair
  ec2_depends_on = [
    module.database.rds,
    module.route53.primary_dns_zone,
    module.network.aws_lb_main,
    module.network.internet_gateway
  ]
}
