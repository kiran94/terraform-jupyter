resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.service}-key"
  public_key = tls_private_key.key.public_key_openssh
  tags       = merge(var.tags, local.builtin_tags)
}

resource "local_file" "pem" {
  filename        = "${aws_key_pair.generated_key.key_name}.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "400"
}
