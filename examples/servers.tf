resource "aws_instance" "web_server" {
  for_each = toset(var.web_server_list)

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3a.micro"
  key_name                    = aws_key_pair.ec2.key_name
  monitoring                  = false
  vpc_security_group_ids      = [module.ec2_sg.this_security_group_id]
  subnet_id                   = tolist(data.aws_subnet_ids.default.ids)[0]
  associate_public_ip_address = true

  user_data = templatefile("./assets/init.sh.tpl", {
    SERVER_NAME = each.key
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = "10"
    encrypted   = true
  }

  tags = merge(
    var.tags, {
      "Name"        = each.key
      "Description" = "Test web server"
    }
  )

  volume_tags = merge(
    var.tags, {
      "Name"       = each.key
      "Mountpoint" = "/"
    }
  )

  lifecycle {
    prevent_destroy = false
  }
}
