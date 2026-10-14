output "vpc_id" {
  value = module.network.vpc_id
}

output "availability_zones" {
  value = module.network.availability_zones
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
