#!/bin/sh
set -u

main() {
    if [ -z "${1+x}" ]; then
        install_dependencies
        setup_cluster
        run_app
        post_install
    else
        if [ "${1}" = "setup" ]; then
            install_dependencies
            setup_cluster
            post_install
        elif [ "${1}" = "run_app" ]; then
            install_dependencies
            run_app
            post_install
        elif [ "${1}" = "run_test" ]; then
            run_test
        fi
    fi
}

setup_cluster() {
    # Environment variables
    UBUNTU_VERSION="$(lsb_release -sr)"
    OS="xUbuntu_${UBUNTU_VERSION}"
    KUBERNETES_VERION="1.26.3"
    CRIO_VERSION=$(echo ${KUBERNETES_VERION} | cut --delimiter="." --fields "1,2")
    CALICO_VERSION="3.25.0"
    CIDR="10.32.0.0/12" # Default CIDR for Flannel/Canal

    add_apt_repos
    install_crio
    install_helm
    install_kube_packages
    system_config_for_kubernetes
    init_kubeadm_cluster
    set_kubeconfig
    install_cluster_addons
    set_single_node_cluster
}

run_app() {
    # Clone the microservices-demo repository
    rm -rf "microservices-demo"
    git clone "https://github.com/microservices-demo/microservices-demo.git" "microservices-demo"

    # Fix for microservices-demo issue #891: https://github.com/microservices-demo/microservices-demo/issues/891
    sed -i 's/readOnlyRootFilesystem: true/readOnlyRootFilesystem: false/g' "microservices-demo/deploy/kubernetes/complete-demo.yaml"

    # Create sock-shop namespace
    kubectl create namespace "sock-shop"
    # Apply sock-shop manifests
    kubectl apply --filename "microservices-demo/deploy/kubernetes/complete-demo.yaml"
}

run_test() {
    frontend_up=false
    echo "Deploying liveness probe"
    while true; do
        FRONTEND_IP=$(kubectl --namespace sock-shop get services/front-end \
            --output jsonpath="{.spec.clusterIP}:{.spec.ports[0].port}" 2>&1)
        if ( (curl -fsSLI "${FRONTEND_IP}" --max-time 0.1 >/dev/null 2>&1)); then
            frontend_up=true
        else
            frontend_up=false
        fi
        if [ ${frontend_up} = true ]; then
            echo "Probe is up <sleeping 5 sec>"
        elif [ ${frontend_up} = false ]; then
            echo "Probe is down <sleeping 5 sec>"
        fi
        sleep "5s"
    done
}

install_dependencies() {
    # Avoid apt interruptions: https://askubuntu.com/questions/1367139/apt-get-upgrade-auto-restart-services
    sudo apt-get --assume-yes autoremove needrestart

    # Install dependencies
    sudo apt-get update
    sudo apt-get install --assume-yes apt-transport-https ca-certificates curl git gnupg lsb-release sed wget
}

add_apt_repos() {
    # Add CRI-O apt repo
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] \
    https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" |
        sudo tee "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list" >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] \
    https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" |
        sudo tee "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list" >/dev/null

    mkdir -p /usr/share/keyrings
    curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key" |
        sudo gpg --batch --yes --dearmor -o "/usr/share/keyrings/libcontainers-archive-keyring.gpg"
    curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/Release.key" |
        sudo gpg --batch --yes --dearmor -o "/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg"

    # Add Kubernetes apt repo
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSLo "/etc/apt/keyrings/kubernetes-archive-keyring.gpg" "https://packages.cloud.google.com/apt/doc/apt-key.gpg"
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" |
        sudo tee "/etc/apt/sources.list.d/kubernetes.list"

    # Add Helm apt repo
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg >/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
        https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

    # update apt to get packages from newly-added repos
    sudo apt-get update
}

install_crio() {
    # Install helm
    sudo apt-get install helm

    # Install cri-o, cri-o-runc and cri-tools
    sudo apt-get --assume-yes install cri-o cri-o-runc cri-tools
    # Reload and enable CRI-O
    sudo systemctl daemon-reload
    sudo systemctl enable crio --now
}

install_kube_packages() {
    # Install kubelet, kubeadm and kubectl
    sudo apt-get update &&
        sudo apt-get install --assume-yes \
            kubelet="${KUBERNETES_VERION}-00" kubeadm="${KUBERNETES_VERION}-00" kubectl="${KUBERNETES_VERION}-00" &&
        sudo apt-mark hold kubelet kubeadm kubectl
}

system_config_for_kubernetes() {
    # Forwarding IPv4 and letting iptables see bridged traffic
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    sudo modprobe overlay
    sudo modprobe br_netfilter
    # sysctl params required by setup, params persist across reboots
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    # Apply sysctl params without reboot
    sudo sysctl --system
    # Verify that the br_netfilter, overlay modules are loaded
    lsmod | grep br_netfilter
    lsmod | grep overlay
    # Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, net.ipv4.ip_forward
    # system variables are set to 1 in your sysctl config
    sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

    # See if swap is enabled
    swapon --show
    # Turn off swap
    sudo swapoff -a
    # Disable swap completely
    sudo sed -i -e '/swap/d' /etc/fstab
}

init_kubeadm_cluster() {
    # Creating a single control-plane cluster with kubeadm
    sudo kubeadm config images pull \
        --kubernetes-version "${KUBERNETES_VERION}" \
        --cri-socket="unix:///var/run/crio/crio.sock"

    sudo kubeadm init \
        --kubernetes-version "${KUBERNETES_VERION}" \
        --cri-socket="unix:///var/run/crio/crio.sock" \
        --pod-network-cidr="${CIDR}" \
        --ignore-preflight-errors="NumCPU"
}

set_kubeconfig() {
    # Set kubeconfig for the current user
    if [ -z "${HOME+x}" ]; then
        true
    else
        mkdir -p "${HOME}/.kube"
        sudo cp -i "/etc/kubernetes/admin.conf" "${HOME}/.kube/config"
        sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"
    fi
}

install_cluster_addons() {
    # Install Canal CNI (Calico for policy and Flannel for networking)
    kubectl apply --filename "https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/canal.yaml"

    # Add Helm repos
    helm repo add containeroo https://charts.containeroo.ch
    helm repo add openebs https://openebs.github.io/charts
    helm repo update

    # Install local-path-provisioner
    helm upgrade --install local-path-provisioner containeroo/local-path-provisioner --namespace=local-path-storage --create-namespace

    # Install OpenEBS CSI
    helm upgrade --install openebs openebs/openebs --namespace=openebs --create-namespace
}

set_single_node_cluster() {
    # Untaint control-plane node to run as single-node cluster
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-
    kubectl taint nodes --all node-role.kubernetes.io/master- >/dev/null 2>&1
}

post_install() {
    # Install back needrestart for interactive use
    sudo apt-get --assume-yes install needrestart
}

main "$@"

exit 0
