#!/bin/bash

sudo mkdir -p /var/lib/{kubelet,kube-proxy,kubernetes}
sudo mkdir -p /var/run/kubernetes
sudo mv bootstrap.kubeconfig /var/lib/kubelet
sudo mv kube-proxy.kubeconfig /var/lib/kube-proxy

wget https://get.docker.com/builds/Linux/x86_64/docker-1.12.6.tgz
tar -xvf docker-1.12.6.tgz
sudo cp docker/docker* /usr/bin/

cat > docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.io

[Service]
ExecStart=/usr/bin/docker daemon \\
  --iptables=false \\
  --ip-masq=false \\
  --host=unix:///var/run/docker.sock \\
  --log-level=error \\
  --storage-driver=overlay
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


sudo mv docker.service /etc/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl enable docker
sudo systemctl start docker
sudo docker version


# CNI 
sudo mkdir -p /opt/cni
wget https://github.com/containernetworking/cni/releases/download/v0.5.2/cni-amd64-v0.5.2.tgz
sudo tar -xvf cni-amd64-v0.5.2.tgz -C /opt/cni

cat > kube.conf <<EOF
{
    "cniVersion": "0.5.2",
    "name": "mynet",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "subnet": "10.200.0.0/16"
    }
}
EOF

sudo mkdir -p /etc/cni/net.d
sudo mv kube.conf /etc/cni/net.d/kube.conf


# kubelet, kube-proxy and kubectl
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kube-proxy
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubelet
chmod +x kubectl kube-proxy kubelet
sudo mv kubectl kube-proxy kubelet /usr/bin/

API_SERVERS=$(sudo cat /var/lib/kubelet/bootstrap.kubeconfig | \
  grep server | cut -d ':' -f2,3,4 | tr '\n' ',' | sed 's/.$//' | tr -d [:space:])

echo "API_SERVERS=$API_SERVERS"

# kubelet
cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --api-servers=${API_SERVERS} \\
  --allow-privileged=true \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=docker \\
  --experimental-bootstrap-kubeconfig=/var/lib/kubelet/bootstrap.kubeconfig \\
  --network-plugin=cni \\
  --network-plugin-dir=/opt/cni/bin  \\
  --cni-conf-dir=/etc/cni/net.d/ \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --serialize-image-pulls=false \\
  --register-node=true \\
  --tls-cert-file=/var/lib/kubelet/kubelet-client.crt \\
  --tls-private-key-file=/var/lib/kubelet/kubelet-client.key \\
  --cert-dir=/var/lib/kubelet \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


sudo mv kubelet.service /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
sudo systemctl status kubelet --no-pager

# kube-proxy
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-proxy \\
  --cluster-cidr=10.200.0.0/16 \\
  --masquerade-all=true \\
  --kubeconfig=/var/lib/kube-proxy/kube-proxy.kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo mv kube-proxy.service /etc/systemd/system/kube-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable kube-proxy
sudo systemctl start kube-proxy
sudo systemctl status kube-proxy --no-pager

