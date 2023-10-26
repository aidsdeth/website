module "resume" {
  source = "./modules/resume"

  region = var.region
  route53_zone_id = var.route53_zone_id
}

module "blog" {
  source = "./modules/blog"

  route53_zone_id = var.route53_zone_id
  region = var.region
}