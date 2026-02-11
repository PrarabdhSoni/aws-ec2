provider "aws" {
    region = var.aws_region
}

resource "aws_security_group" "web_sg" {
    name = "terraform-web-sg"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 22
        to_port = 22
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

resource "aws_launch_template" "web_template" {
    name_prefix = "web_template"
    image_id = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name

    network_interfaces {
        associate_public_ip_address = true
        security_groups = [aws_security_group.web_sg.id]
    }

    user_data = base64encode(file("userdata.sh"))
}

resource "aws_lb_target_group" "tg" {
    name = "terraform-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
}

resource "aws_lb" "alb" {
    name = "terraform-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.web_sg.id]
    subnets = ["subnet-0f9ab71af1374a25e", "subnet-0e4b5873994209046"]
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}

resource "aws_autoscaling_group" "asg"{
    desired_capacity = 2
    max_size = 3
    min_size = 1

    vpc_zone_identifier = ["subnet-0f9ab71af1374a25e", "subnet-0e4b5873994209046"]

    target_group_arns = [aws_lb_target_group.tg.arn]

    launch_template {
        id = aws_launch_template.web_template.id
        version = "$Latest"
    }
}