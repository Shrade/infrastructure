resource "aws_iam_group" "example" {
  name = "admin-shrade"
  path = "/admin/"
}

resource "aws_iam_policy" "example" {
  name        = "my-user-group-policy"
  description = "Example IAM policy for my user group"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_group_policy_attachment" "example" {
  group      = aws_iam_group.example.name
  policy_arn = aws_iam_policy.example.arn
}