variable "aws_region" {
    default = "ap-south-1"
}

variable "ami_id" {
    default = "ami-00d2efe5bc0683614"
}

variable "instance_type" {
    default = "t3.micro"
}

variable "key_name" {
    description = "awsKey"
}

variable "vpc_id" {
    description = "vpc-0749b56d732f15e32"
}