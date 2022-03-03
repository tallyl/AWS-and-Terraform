
output "s3_ngnix_ec2_role" {
  description = "Public IP address of the EC2 instance"
  value       = aws_iam_instance_profile.s3_ngnix_ec2_role.id
}
