resource "aws_vpc" "kubeadm_vpc" {
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "kubeadm_vpc"
  }
}

resource "aws_subnet" "kubeadm_subnet" {
  vpc_id            = aws_vpc.kubeadm_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_internet_gateway" "kubeadm_igw" {
  vpc_id = aws_vpc.kubeadm_vpc.id
}

resource "aws_route_table" "kubeadm_rtb" {
  vpc_id = aws_vpc.kubeadm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_igw.id
  }
}

resource "aws_route_table_association" "kubeadm_rtb_association" {
  subnet_id      = aws_subnet.kubeadm_subnet.id
  route_table_id = aws_route_table.kubeadm_rtb.id
}
