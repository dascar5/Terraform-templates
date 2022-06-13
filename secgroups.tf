resource "aws_security_group" "alb" {
  name = "ldi-app-security-group-alb-${var.env}-${substr(uuid(), 0, 3)}"
  description = "alb"
  vpc_id      = "${var.vpcid}"

  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      description = "Security Group for deployment"
      self = false
    }
  ]

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.9.0/24", "10.129.109.0/24", "10.9.184.0/24", "10.9.184.0/24","172.23.192.0/23", "172.23.206.0/23", "172.23.208.0/21", "172.23.240.0/21", "172.29.192.0/23", "172.29.206.0/23", "172.29.208.0/21", "172.29.240.0/21", "172.26.192.0/20", "192.168.102.0/24"]
    description = ""
    security_groups = ["${data.aws_ssm_parameter.ui_sg_alb_id.value}","${data.aws_ssm_parameter.ui_sg_container_id.value}","${data.aws_ssm_parameter.searchwatch_sg.value}"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.9.0/24", "10.129.109.0/24", "10.9.184.0/24", "10.9.184.0/24","172.23.192.0/23", "172.23.206.0/23", "172.23.208.0/21", "172.23.240.0/21", "172.29.192.0/23", "172.29.206.0/23", "172.29.208.0/21", "172.29.240.0/21", "172.26.192.0/20", "192.168.102.0/24"]
    description = ""
    security_groups = ["${data.aws_ssm_parameter.ui_sg_alb_id.value}","${data.aws_ssm_parameter.ui_sg_container_id.value}","${data.aws_ssm_parameter.searchwatch_sg.value}"]
  }
}

resource "aws_security_group" "container" {
  name = "ldi-app-security-group-container-${var.env}-${substr(uuid(), 0, 3)}"
  description = "container"
  vpc_id      = "${var.vpcid}"

  lifecycle {
      create_before_destroy = true
      ignore_changes        = [name]
  }

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      description = "Security Group for deployment"
      self = false
    }
  ]

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = ""
    security_groups = ["${aws_security_group.alb.id}","${data.aws_ssm_parameter.ui_sg_alb_id.value}","${data.aws_ssm_parameter.ui_sg_container_id.value}","${data.aws_ssm_parameter.searchwatch_sg.value}"]
  }

  ingress {
    from_port = 5001
    to_port = 5001
    protocol = "tcp"
    description = ""
    security_groups = ["${aws_security_group.alb.id}","${data.aws_ssm_parameter.ui_sg_alb_id.value}","${data.aws_ssm_parameter.ui_sg_container_id.value}","${data.aws_ssm_parameter.searchwatch_sg.value}"]
  }
}

resource "aws_ssm_parameter" "container_sg_id" {
  name  = "/ldi/${var.env}/app_cluster/container_sg"
  type  = "String"
  value = aws_security_group.container.id
}

resource "aws_ssm_parameter" "alb_sg_id" {
  name  = "/ldi/${var.env}/app_cluster/alb_sg"
  type  = "String"
  value = aws_security_group.alb.id
}

data "aws_ssm_parameter" "ui_sg_alb_id" {
  name = "/ldi/${var.env}/ui_cluster/alb_sg"
}

data "aws_ssm_parameter" "ui_sg_container_id" {
  name = "/ldi/${var.env}/ui_cluster/container_sg"
}

data "aws_ssm_parameter" "searchwatch_sg" {
  name = "/ldi/${var.env}/searchwatch/lambda_sg"
}