resource "aws_instance" "web" {
  tags = {
    Name = var.instance_name
  }

  ami             = data.aws_ami.ubuntu2204-minimal.id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.sg_name]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = var.volume_type
    volume_size           = var.volume_size
  }

  # user_data = filebase64("${path.module}/user_data/task.sh")
}
