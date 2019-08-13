resource "aws_iam_service_linked_role" "search" {
  aws_service_name = "es.amazonaws.com"
}
