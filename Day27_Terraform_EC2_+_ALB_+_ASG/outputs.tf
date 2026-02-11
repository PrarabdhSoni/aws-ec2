output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}

output "asg_name" {
    value = aws_autoscaling_group.asg.name
}