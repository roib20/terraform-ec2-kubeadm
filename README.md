# terraform-ec2-kubeadm

[![License](https://img.shields.io/badge/license-Apache--2.0-green)](https://opensource.org/license/apache2-0/)
[![ShellCheck](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml)

This Terraform project provisions an EC2 instance, then using [User data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) a shell script is deployed which creates a single node control-plane cluster with kubeadm. A test application is deployed: [Microservices Demo](https://microservices-demo.github.io/) by [Weaveworks](https://www.weave.works/) and [Container Solutions](https://www.container-solutions.com/).
