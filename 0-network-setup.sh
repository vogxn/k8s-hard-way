#!/bin/bash

# using the region as us-centra1

gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-f

# Set up networks
NETWORK_NAME="kubernetes-the-hard-way"
SUBNETWORK_NAME="kubernetes"
gcloud compute networks create $NETWORK_NAME --mode custom 

gcloud compute networks subnets create $SUBNETWORK_NAME \
  --network $NETWORK_NAME \
  --range 10.240.0.0/24 \
  --region us-central1

gcloud compute firewall-rules create allow-internal \
  --allow tcp,udp,icmp \
  --network $NETWORK_NAME \
  --source-ranges 10.240.0.0/24,10.200.0.0/16

gcloud compute firewall-rules create allow-external \
  --allow tcp:22,tcp:3389,tcp:6443,icmp \
  --network $NETWORK_NAME \
  --source-ranges 0.0.0.0/0

gcloud compute firewall-rules create allow-healthz \
  --allow tcp:8080 \
  --network $NETWORK_NAME \
  --source-ranges 130.211.0.0/22

# list the created networks
gcloud compute firewall-rules list --filter "network=$NETWORK_NAME"

# setup public address for k8s load balancer
gcloud compute addresses create $NETWORK_NAME --region=us-central1
gcloud compute addresses list $NETWORK_NAME
