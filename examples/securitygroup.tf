module "ec2_sg" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.18.0"

  use_name_prefix = false
  name            = "ec2-sg"
  description     = "ec2 SG Rules"
  vpc_id          = data.aws_vpc.default.id

  ###################
  ## INGRESS RULES ##
  ###################

  ### Self Ingress Rules
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  ### Normal Ingress Rules
  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = local.external_ip
    }
  ]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      description              = "Allow access from ALB"
      source_security_group_id = module.lb_sg.this_security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  ##################
  ## EGRESS RULES ##
  ##################

  ### Self Engress Rules
  egress_with_self = [
    {
      rule = "all-all"
    }
  ]

  ### Normal Egress Rules
  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp"]

  egress_with_cidr_blocks = [
    {
      from_port   = 9418
      to_port     = 9418
      protocol    = "tcp"
      description = "Allow outbound to Git"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  #################
  # STANDARD RULE #
  #################
  ## NOTE: This is required to bypass SG module issue
  egress_ipv6_cidr_blocks                         = []
  egress_with_ipv6_cidr_blocks                    = []
  computed_egress_with_ipv6_cidr_blocks           = []
  number_of_computed_egress_with_ipv6_cidr_blocks = 0

  ##########
  ## Tags ##
  ##########
  tags = var.tags
}

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.17.0"

  use_name_prefix = false
  name            = "example-lb-sg"
  description     = "example lb sg rules"
  vpc_id          = data.aws_vpc.default.id


  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "ALB redirect to 443"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows external connectivity via https"
    },
  ]


  computed_egress_with_source_security_group_id = [
    {
      rule                     = "all-tcp"
      description              = "Allow ALB TCP Health Check"
      source_security_group_id = module.ec2_sg.this_security_group_id
    },
  ]
  number_of_computed_egress_with_source_security_group_id = 1


  egress_ipv6_cidr_blocks                         = []
  egress_with_ipv6_cidr_blocks                    = []
  computed_egress_with_ipv6_cidr_blocks           = []
  number_of_computed_egress_with_ipv6_cidr_blocks = 0

  tags = null
}
