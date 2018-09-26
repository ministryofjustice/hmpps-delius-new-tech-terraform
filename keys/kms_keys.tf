module "master_key" {
  source = "./modules/encryption_key"
  key_name = "master"
  tags = "${var.tags}"
}

