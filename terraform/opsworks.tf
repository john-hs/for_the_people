resource "aws_iam_role" "for-the-people-opsworks-service" {
  name = "for-the-people-opsworks-service"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "opsworks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "for-the-people-opsworks-ec2" {
  name = "for-the-people-opsworks-ec2"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "for-the-people-opsworks-service" {
  name = "for-the-people-opsworks-service"
  role = "${aws_iam_role.for-the-people-opsworks-service.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "ec2:*",
                "iam:PassRole",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:DescribeAlarms",
                "ecs:*",
                "elasticloadbalancing:*",
                "rds:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "for-the-people-opsworks-ec2" {
  name  = "for-the-people-opsworks-ec2"
  roles = ["${aws_iam_role.for-the-people-opsworks-ec2.name}"]
}

resource "aws_opsworks_stack" "for-the-people-stack" {
  name                          = "for-the-people-stack"
  region                        = "${var.aws_region}"
  service_role_arn              = "${aws_iam_role.for-the-people-opsworks-service.arn}"
  default_instance_profile_arn  = "${aws_iam_instance_profile.for-the-people-opsworks-ec2.arn}"
  configuration_manager_version = "11.10"
  default_os                    = "Amazon Linux 2016.03"
  default_ssh_key_name          = "JohnAWS"
  vpc_id						= "${var.default_vpc}"
  default_subnet_id				= "${var.default_subnet}"
}

resource "aws_opsworks_static_web_layer" "web" {
  stack_id = "${aws_opsworks_stack.for-the-people-stack.id}"
  name = "Static Site Layer"
  auto_healing     = true
  elastic_load_balancer = "for-the-people-web-elb"
  auto_assign_public_ips = true
}

resource "aws_opsworks_application" "for-the-people-app" {
  name        = "For the People application"
  short_name  = "ftp-app"
  stack_id    = "${aws_opsworks_stack.for-the-people-stack.id}"
  type        = "static"
  app_source = {
    type     = "git"
    revision = "master"
    url      = "https://github.com/john-hs/for_the_people.git"
  }
}


resource "aws_opsworks_instance" "web1" {
  stack_id = "${aws_opsworks_stack.for-the-people-stack.id}"
  layer_ids = [
    "${aws_opsworks_static_web_layer.web.id}",
  ]
  instance_type    = "t2.micro"
  state            = "running"
  root_device_type = "ebs"
  hostname		   = "web1"
}

resource "aws_opsworks_instance" "web2" {
  stack_id = "${aws_opsworks_stack.for-the-people-stack.id}"
  layer_ids = [
    "${aws_opsworks_static_web_layer.web.id}",
  ]
  instance_type    = "t2.micro"
  state            = "running"
  root_device_type = "ebs"
  hostname		   = "web2"
}
