provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
	cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
	vpc_id = aws_vpc.my_vpc.id
	cidr_block = "10.0.1.0/24"
	availability_zone = "us-east-1a"
}

resource "aws_security_group" "sample_sg"{
	vpc_id = aws_vpc.my_vpc.id

	ingress {
		from_port = 443
		to_port = 443
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "some_ec2_1"{
	ami = "ami_id"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.my_subnet.id
	security_groups = [aws_security_group.sample_sg.id]
}

resource "aws_instance" "some_ec2_2"{
	ami = "ami_id"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.my_subnet.id
	security_groups = [aws_security_group.sample_sg.id]
}

resource "aws_lb" "my_lb"{
	name = "sample-lb"
	internal = false
	load_balancer_type = "application"
	security_groups    = [aws_security_group.sample_sg.id]
  	subnets            = [aws_subnet.my_subnet.id]
}

resource "aws_lb_target_group" "sample_tg"{
	name = "sample-tg"
	port = 80
	protocol = "HTTP"
	vpc_id = aws_vpc.my_vpc.id

	health_check {
		path = "/"
		protocol = "HTTP"
		port = "traffic-port"
		healthy_threshold = 2
		unhealthy_threshold = 2
		timeout = 3
		interval = 30
	}
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "instance1_attachment" {
	target_group_arn = aws_lb_target_group.sample_tg.arn
	target_id = aws_instance.some_ec2_1.id
	port = 80
}

resource "aws_lb_target_group_attachment" "instance2_attachment" {
	target_group_arn = aws_lb_target_group.sample_tg.arn
	target_id = aws_instance.some_ec2_2.id
	port = 80
}



























