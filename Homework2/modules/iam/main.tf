/*
  IAM Roles - for s3 logs sending
*/
resource "aws_iam_role" "s3_ngnix_iam_role" {
  name = "${var.deployment_name}-ROLE"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_ngnix_iam_role_policy" {
  name = "${var.deployment_name}-POLICY"
  role = "${aws_iam_role.s3_ngnix_iam_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*",
                "arn:aws:s3:::${var.bucket_name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListObjectsV2",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*",
                "arn:aws:s3:::${var.bucket_name}"
            ]
        }
    ]
}
EOF
}

//resource "aws_iam_role_policy_attachment" "attach_logs" {
//  role       = aws_iam_role.s3_ngnix_iam_role.id
//  policy_arn = "arn:aws:iam::aws:policy/${aws_iam_role_policy.s3_ngnix_iam_role_policy.name}"
//}

resource "aws_iam_instance_profile" "s3_ngnix_ec2_role" {
  name = "${var.deployment_name}-ngnix--EC2ROLE"
  role = "${aws_iam_role.s3_ngnix_iam_role.name}"
}
