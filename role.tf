resource "aws_iam_instance_profile" "wp_node" {
  name = "EC2_instance_profile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_iam_role" "ec2_role" {
  name               = "WordPressRole"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "get_ssm_parameters_policy" {
  name   = "get_ssm_parameters_policy"
  role   = "${aws_iam_role.ec2_role.name}"
  policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "ssm:DescribeParameters"
              ],
              "Resource": "*"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "ssm:GetParameter"
              ],
              "Resource": "${aws_ssm_parameter.rds_password.arn}"
          }
      ]
}
EOF
}
