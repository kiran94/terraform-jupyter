
resource "aws_ebs_volume" "jupyter" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume_size_gb
  type              = "gp2"
  tags              = merge(var.tags, local.builtin_tags)
}

resource "aws_volume_attachment" "jupyter" {
  device_name  = "/dev/sdb"
  instance_id  = aws_instance.jupyter.id
  volume_id    = aws_ebs_volume.jupyter.id
  force_detach = true
}
