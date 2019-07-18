variable "casenotes_conf" {
  description = "Config map for case notes poll/push task"
  type        = "map"

  default = {
    image         = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-casenotes"
    image_version = "latest"
    memory        = "512"
  }
}
