# terraform-ec2-kubeadm

[![License](https://img.shields.io/badge/license-Apache--2.0-green)](https://opensource.org/license/apache2-0/)
[![ShellCheck](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/roib20/terraform-ec2-kubeadm/actions/workflows/shellcheck.yml)

This Terraform project provisions an EC2 instance, then using [User data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) a shell script is deployed which creates a single node Kubernetes cluster with [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/). Then a test application is deployed on the cluster: [Microservices Demo](https://microservices-demo.github.io/) by [Weaveworks](https://www.weave.works/) and [Container Solutions](https://www.container-solutions.com/).

### Shell script
The `task.sh` User data shell script is written using POSIX Shell so that it can run on [dash](https://wiki.ubuntu.com/DashAsBinSh) (instead of bash). The `set -u` option is set to ensure that variables are always set correctly. Furthermore, [ShellCheck](https://github.com/koalaman/shellcheck) is used together with [a GitHub Action](https://github.com/marketplace/actions/shellcheck), to ensure best practices for shell scripts.

### Kubeadm Kubernetes cluster
Some cluster add-ons are installed. [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/) is used as the cluster's [CNI](https://github.com/containernetworking/cni). Canal uses Calico for policy and Flannel for networking. The reason I decided to use Canal for this project is that I wanted a simple CNI like Flannel, but with support for [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) using Calico. For storage, [local-path-provisioner](https://github.com/rancher/local-path-provisioner) and [OpenEBS](https://openebs.io/) are installed.

The container runtime used in this project is [CRI-O](https://github.com/cri-o/cri-o). I found CRI-O simpler to install than [containerd](https://containerd.io/), and I especially appreciated the consistent versioning which makes it easy to match CRI-O with an appropriate Kubernetes version.

### Operating system
Ubuntu Minimal 22.04 LTS is recommended (and is used by default), however this project was also tested on Ubuntu 18.04 LTS and Ubuntu 20.04 LTS.

## FAQ
### How to deploy this on AWS?
1) Create an [SSH Key Pair for AWS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

2) Install Terraform and ensure it can deploy AWS resources to your account.

3) Clone this repository.

4) Edit the `terraform.tfvars.example` file:
* Use the command: `cp "terraform.tfvars.example" "terraform.tfvars"`
* Edit `terraform.tfvars` using a text editor; add all necessary values (including your IP and Key Pair name).

5) Run `terraform init && terraform apply` from the project directory.

6) When Terraform completes, wait a few minutes for the User data shell script to complete in the backgroud.

7) SSH into your newly created Ubuntu EC2 instance using the following command:
```
ssh "$(terraform output --raw instance_public_ip)" -l "ubuntu"
```

8) Run `kubectl get pods -A` to ensure everything deployed correctly (note: some pods could take several minutes to start).

9) You can check the liveness of the app by running the `task.sh` shell script with the `run_test` flag:
```
curl -fsSL https://raw.githubusercontent.com/roib20/terraform-ec2-kubeadm/main/user_data/task.sh | /bin/sh -s -- run_test
```

### How to destroy this on AWS?
Just run `terraform destroy` from the project directory.

### How to deploy this on an Ubuntu VM?
1) Install an Ubuntu 22.04 LTS VM [using Proxmox VE](https://github.com/roib20/proxmox-scripts/tree/main/proxmox-cloudinit-script) or another hypervisor. Non-VM installs are not recommended because the script does a lot of changes to a system.

2) SSH into your Ubuntu VM, run the `task.sh` script using this command:
```
curl -fsSL https://raw.githubusercontent.com/roib20/terraform-ec2-kubeadm/main/user_data/task.sh | /bin/sh -s --
```

3) Once the script completes, check if `kubectl` is working. If not, try runnig these commands:
```
mkdir -p "${HOME}/.kube"
sudo cp -i "/etc/kubernetes/admin.conf" "${HOME}/.kube/config"
sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"
```

4) Run `kubectl get pods -A` to ensure everything deployed correctly (note: some pods could take several minutes to start).

5) You can check the liveness of the app by running the `task.sh` shell script with the `run_test` flag:
```
curl -fsSL https://raw.githubusercontent.com/roib20/terraform-ec2-kubeadm/main/user_data/task.sh | /bin/sh -s -- run_test
```
