locals {
  ips = {
    "10.0.1.0/24" = "AWS1 VPC RDP Hosts"
    "10.0.9.0/24" = "AWS1 VPC RDP Hosts"
    "10.129.109.0/24" = "AWS VPN"
    "10.9.184.0/24" = "aws workspaces"
    "172.23.192.0/23" = "DC3 Jump Servers"
    "172.23.206.0/23" = "VPN Subnet"
    "172.23.208.0/21" = "VPN Subnet"
    "172.23.240.0/21" = "VPN Subnet"
    "172.29.192.0/23" = "TR2 Jump Servers"
    "172.29.206.0/23" = "VPN Subnet"
    "172.29.208.0/21" = "VPN Subnet"
    "172.29.240.0/21" = "VPN Subnet"
    "172.26.192.0/20" = "TWM"
  }
}

  dynamic "ingress" {
    for_each = local.ips
    content {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [ingress.key]
      description = ingress.value
      security_groups = ["${data.aws_ssm_parameter.ui_sg_alb_id.value}","${data.aws_ssm_parameter.ui_sg_container_id.value}","${data.aws_ssm_parameter.searchwatch_sg.value}","${data.aws_ssm_parameter.process_sg.value}"]
    }
  }
