resource "aws_instance" "web" {
  tags = {
    Name = var.instance_name
  }

  ami                    = data.aws_ami.ubuntu2204-minimal.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.kubeadm_subnet.id
  vpc_security_group_ids = ["${aws_security_group.kubeadm_sg.id}"]

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = var.volume_type
    volume_size           = var.volume_size
  }

  user_data = filebase64("${path.module}/user_data/task.sh")
}
