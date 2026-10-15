module "network" {
  source = "../../modules/network"

  name     = "dev"
  vpc_cidr = "10.0.0.0/16"
  az_count = 2
}

module "compute" {
  source = "../../modules/compute"

  name             = "dev"
  vpc_id           = module.network.vpc_id
  subnet_id        = module.network.public_subnet_ids[0]
  ssh_allowed_cidr = var.ssh_allowed_cidr
  ssh_public_key   = var.ssh_public_key
}
