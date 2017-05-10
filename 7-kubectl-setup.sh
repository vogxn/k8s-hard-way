#!/usr/bin/bash

#wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/darwin/amd64/kubectl
#chmod +x kubectl
#sudo mv kubectl /usr/local/bin

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region us-central1 \
  --format 'value(address)')

pushd certs

kubectl config set-cluster kubernetes-the-hard-way \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem
kubectl config set-context kubernetes-the-hard-way \
  --cluster=kubernetes-the-hard-way \
  --user=admin
kubectl config use-context kubernetes-the-hard-way

popd

kubectl get componentstatuses

kubectl get nodes



