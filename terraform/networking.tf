resource "aws_security_group" "for-the-people-elb-sg" {
  name        = "for-the-people-elb-sg"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "for-the-people-web-elb" {
  name = "for-the-people-web-elb"

  subnets         = ["${var.default_subnet}"]
  security_groups = ["${aws_security_group.for-the-people-elb-sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  lifecycle {
    create_before_destroy = true
  }
}