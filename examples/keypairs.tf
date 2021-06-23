resource "aws_key_pair" "ec2" {
  key_name   = "temp-ec2-key"
  public_key = tls_private_key.ec2.public_key_openssh
}

resource "tls_private_key" "ec2" {
  algorithm = "RSA"
}

resource "local_file" "id_rsa_pem" {
  content         = tls_private_key.ec2.private_key_pem
  filename        = "${path.cwd}/assets/id_rsa.pem"
  file_permission = "0600"
}

resource "local_file" "id_rsa_pub" {
  content         = tls_private_key.ec2.public_key_openssh
  filename        = "${path.cwd}/assets/id_rsa.pub"
  file_permission = "0600"
}