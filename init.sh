# Turn off swap
swapoff -a
cat <<EOF >> sudo /etc/fstab
none        /var/run        tmpfs   size=1M,noatime         00
none        /var/log        tmpfs   size=1M,noatime         00
EOF
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

# Install docker and kubernetes
apt install docker.io -y
systemctl enable docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee --append /etc/apt/sources.list
apt update
apt install kubeadm -y
hostnamectl set-hostname slave-node
free -m
docker --version
kubeadm version

# This part is for Master node

kubeadm init --pod-network-cidr=10.10.0.0/16
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get pods --all-namespaces
kubectl get nodes
