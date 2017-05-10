#!/bin/bash

DISK_SIZE="200GB"
IMAGE="ubuntu-1604-xenial-v20170307"
IMAGE_PROJECT="ubuntu-os-cloud"
MACHINE_TYPE="n1-standard-1"  # 3.75GB RAM, 1 vCPU
SUBNETWORK="kubernetes"


# Controllers
OCTET=10 # Start octet - 10.240.0.(10|11|12)
for controller in controller0; do
  gcloud compute instances create $controller \
    --boot-disk-size $DISK_SIZE \
    --can-ip-forward \
    --image $IMAGE \
    --image-project $IMAGE_PROJECT \
    --machine-type $MACHINE_TYPE \
    --private-network-ip 10.240.0.$OCTET \
    --subnet $SUBNETWORK

  ((OCTET++))
done

# Workers
OCTET=20 # Start octet - 10.240.0.(20|21|22)
for worker in worker0 worker1; do
  gcloud compute instances create $worker \
    --boot-disk-size $DISK_SIZE \
    --can-ip-forward \
    --image $IMAGE \
    --image-project $IMAGE_PROJECT \
    --machine-type $MACHINE_TYPE \
    --private-network-ip 10.240.0.$OCTET \
    --subnet $SUBNETWORK

  ((OCTET++))
done
