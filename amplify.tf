resource "aws_amplify_app" "wildrydes-site" {
  name       = "wildrydes-site"
  repository = "https://git-codecommit.ap-south-1.amazonaws.com/v1/repos/wildrydes-site"
  

  
  build_spec = <<-EOF
  version: 1
  frontend:
    phases:
      build:
        commands: []
    artifacts:
      baseDirectory: /
      files:
        - '**/*'
    cache:
      paths: []
  EOF

  iam_service_role_arn = aws_iam_role.amplify_codecommit_role.arn
  
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.wildrydes-site.id
  branch_name = "main"
}

resource "aws_iam_policy" "amplify_codecommit" {
  name        = "AmplifyCodeCommit"
  description = "IAM policy for Amplify CodeCommit and CloudWatch Logs access"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PushLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:ap-south-1:390755846846:log-group:/aws/amplify/*:log-stream:*"
        },
        {
            "Sid": "CreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-south-1:390755846846:log-group:/aws/amplify/*"
        },
        {
            "Sid": "DescribeLogGroups",
            "Effect": "Allow",
            "Action": "logs:DescribeLogGroups",
            "Resource": "arn:aws:logs:ap-south-1:390755846846:log-group:*"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:codecommit:ap-south-1:390755846846:wildrydes-site"
            ],
            "Action": [
                "codecommit:GitPull"
            ]
        }
    ],
  })
}

resource "aws_iam_role" "amplify_codecommit_role" {
  name = "amplify-codecommit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "amplify.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_policy_attachment" "amplify_codecommit_attachment" {
  name       = "amplify-codecommit-attachment"
  roles      = [aws_iam_role.amplify_codecommit_role.name]
  policy_arn = aws_iam_policy.amplify_codecommit.arn

}
