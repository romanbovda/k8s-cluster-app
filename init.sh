#!/usr/bin/env bash
# Turn off swap
sudo su
swapoff -a
cat <<EOF >> sudo /etc/fstab
none        /var/run        tmpfs   size=1M,noatime         00
none        /var/log        tmpfs   size=1M,noatime         00
EOF
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile remove

cat <<EOF > /boot/firmware/cmdline.txt
cgroup_enable=memory cgroup_memory=1
EOF

# Install docker and kubernetes
apt install docker.io -y
systemctl enable docker
hostnamectl set-hostname slave-node
free -m
docker --version
snap install microk8s --classic --channel=latest/stable
snap info microk8s
microk8s enable dashboard dns ingress metallb metrics-server rbac registry storage
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
kubectl apply -f pihole/pihole.deploy.yml
kubectl apply -f pihole/rbac.yml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
helm install prometheus stable/prometheus --namespace monitoring
helm install stable/grafana -f monitoring/grafana/values.yml --namespace monitoring

# Optional relaunch deployment with capable images
# https://stackoverflow.com/questions/42885538/raspberry-pi-docker-error-standard-init-linux-go178-exec-user-process-caused
kubectl delete deployment grafana -n monitoring
kubectl delete deployment prometheus-kube-state-metrics -n monitoring
kubectl apply -f monitoring/grafana/grafana.yml
kubectl apply -f monitoring/prometheus.yml
#=====-----

kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# port forwarding
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace monitoring port-forward $POD_NAME 3000

# backup
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts