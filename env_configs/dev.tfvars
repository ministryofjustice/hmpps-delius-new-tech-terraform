vpc_cidr = "10.161.73.0/24"

project_name = "delius-new-tech"
environment_type = "dev"
engineering_account_id = "895523100917"
ci_vpc_cidr = "10.161.96.0/24"
ci_vpc_id = "vpc-02321f288159e5d0e"
bastion_vpc_cidr = "10.161.98.0/25"
bastion_vpc_id = "vpc-00d48e9851c261b47"
world_access = "true"
az_count = 2
alarms_enabled = "false"

pdf_generator_min_asg_size = 1
pdf_generator_max_asg_size = 4
pdf_generator_instance_type = "t2.micro"
pdf_generator_lower_cpu_trigger = 5
pdf_generator_upper_cpu_trigger = 10
pdf_generator_debug_log = "true"

tags = {
  owner = "Digital Studio",
  environment-name = "delius-new-tech-dev",
  application = "Delius"
  is-production = "false",
  business-unit = "HMPPS",
  infrastructure-support = "Digital Studio"
}
