# ## Commented out example ##

## ECS Task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


## ECS Task role"
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com", "quicksight.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}


resource "aws_iam_policy" "ecspolicy" {
  name        = "ecs-task-custom-policy"
  description = "ECS Task Policy"
  policy      = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
       "Effect": "Allow",
       "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
       ],
      "Resource": "*"
      },
       {
       "Effect": "Allow",
       "Action": "quicksight:*",
      "Resource": "*"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_exec" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecspolicy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_dynamo" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


resource "aws_iam_policy" "quicksight_policy" {
  name        = "ecs-fe-quicksight-policy"
  description = "ECS Task Policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "quicksight:RegisterUser",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "quicksight:GetDashboardEmbedUrl",
            "Resource": "arn:aws:quicksight:eu-central-1:812222239604:dashboard/70e99648-2579-4784-9f6f-d6056bdff9d8",
            "Effect": "Allow"
        },
        {
            "Action": "sts:AssumeRole",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "quicksight_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.quicksight_policy.arn
}


## Glue Catalog Table ## 
resource "aws_iam_role" "glue_data_quality_role" {
  name               = "glue-data-quality-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "glue.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "scheduler.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
} 
EOF
}


resource "aws_iam_policy" "glue_data_quality_policy" {
  name        = "glue-data-quality-policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "glue:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "cloudwatch:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "s3:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "logs:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "sqs:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "events:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "scheduler:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "schemas:*",
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Action": "iam:PassRole",
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "glue_data_quality_policy_attachment" {
  role       = aws_iam_role.glue_data_quality_role.name
  policy_arn = aws_iam_policy.glue_data_quality_policy.arn
}