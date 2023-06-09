resource "aws_iam_group" "that" {
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

resource "aws_iam_user" "shrade_general" {
  name = "shrade-general"
}

resource "aws_iam_group_policy_attachment" "that" {
  group      = aws_iam_group.that.name
  policy_arn = aws_iam_policy.that.arn
}

resource "aws_iam_user_policy_attachment" "that" {
  user      = aws_iam_user.shrade_general.name
  policy_arn = aws_iam_policy.that.arn
}