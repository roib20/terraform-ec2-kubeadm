# terraform-ec2-kubeadm

[![License](https://img.shields.io/badge/license-Apache--2.0-green)](https://opensource.org/license/apache2-0/)
[![ShellCheck](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml)

This Terraform project provisions an EC2 instance, then using [User data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) a shell script is deployed which creates a single node Kubernetes cluster with [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/). Then a test application is deployed on the cluster: [Microservices Demo](https://microservices-demo.github.io/) by [Weaveworks](https://www.weave.works/) and [Container Solutions](https://www.container-solutions.com/).

## Shell script
The `task.sh` User data shell script is written using POSIX Shell so that it can run on [dash](https://wiki.ubuntu.com/DashAsBinSh) (instead of bash). The `set -u` option is set to ensure that variables are always set correctly. Furthermore, [ShellCheck](https://github.com/koalaman/shellcheck) is used together with [a GitHub Action](https://github.com/marketplace/actions/shellcheck), to ensure best practices for shell scripts.

## Kubeadm Kubernetes cluster
Some cluster add-ons are installed. [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/) is used as the cluster's [CNI](https://github.com/containernetworking/cni). Canal uses Calico for policy and Flannel for networking. The reason I decided to use Canal for this project is that I wanted a simple CNI like Flannel, but with support for [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) using Calico. For storage, [local-path-provisioner](https://github.com/rancher/local-path-provisioner) and [OpenEBS](https://openebs.io/) are installed.

The container runtime used in this project is [CRI-O](https://github.com/cri-o/cri-o). I found CRI-O simpler to install than [containerd](https://containerd.io/), and I especially appreciated the consistent versioning which makes it easy to match CRI-O with an appropriate Kubernetes version.