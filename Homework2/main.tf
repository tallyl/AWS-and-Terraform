module "create_vpc" {
  source ="./modules/vpc"
  common_tags = var.common_tags
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  vpc_cidr_block = var.vpc_cidr_block
  azs = var.azs
}

module "create_network" {
  source = "./modules/network"
  common_tags = var.common_tags
  sg_ingress_rules = var.sg_ingress_rules
  azs = var.azs
  private_subnets = module.create_vpc.private_subnet
  public_subnets = module.create_vpc.public_subnet
  deployment_name = var.deployment_name
  vpc_id = module.create_vpc.vpc_id
}

module "create_iam" {
  source = "./modules/iam"
  bucket_name = "${local.deployment_name}-ngnix-bucket"
}


module "ec2_app" {
  source ="./modules/ec2"
  instance_type = var.instance_type
  deployment_name = local.deployment_name
  web_ebs_volume_size = var.web_ebs_volume_size
  web_instance_count = var.web_instance_count
  public_subnet_ids = module.create_vpc.public_subnet
  web_sg = module.create_network.nginix_sg_id
  private_subnet_ids = module.create_vpc.private_subnet
  common_tags = var.common_tags
  bucket_name = "${local.deployment_name}-ngnix-bucket"
  acl_value = var.acl_value
  ami_id = var.ami_id
  azs = var.azs
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets
  iam_instance_profile = module.create_iam.s3_ngnix_ec2_role
}

module "create_alb" {
  source ="./modules/alb"

  deployment_name = local.deployment_name
  forwarding_config = var.forwarding_config
  web_servers = module.ec2_app.web_server
  public_subnets = module.create_vpc.public_subnet
  sg_id = module.create_network.nginix_sg_id
  common_tags = var.common_tags
  vpc_id = module.create_vpc.vpc_id
}
