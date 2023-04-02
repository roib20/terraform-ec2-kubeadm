# Ubuntu 22.04 LTS (Jammy Jellyfish)
data "aws_ami" "ubuntu2204" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu2204-minimal" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Ubuntu 20.04 LTS (Focal Fossa)
data "aws_ami" "ubuntu2004" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu2004-minimal" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-focal-20.04-amd64-minimal-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# Ubuntu 18.04 LTS (Bionic Beaver)
data "aws_ami" "ubuntu1804" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu1804-minimal" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-bionic-18.04-amd64-minimal-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
