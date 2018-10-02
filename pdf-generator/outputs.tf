output "asg_name" {
  value = "${aws_elastic_beanstalk_environment.eb_environment.autoscaling_groups[0]}"
}

output "elb_name" {
  value = "${aws_elastic_beanstalk_environment.eb_environment.load_balancers[0]}"
}
