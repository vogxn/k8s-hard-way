#!/bin/bash

gcloud -q compute instances delete \
    controller0 \
      worker0 worker1

gcloud -q compute forwarding-rules delete kubernetes-forwarding-rule --region us-central1

gcloud -q compute target-pools delete kubernetes-target-pool

gcloud -q compute http-health-checks delete kube-apiserver-health-check

gcloud -q compute addresses delete kubernetes-the-hard-way --region us-central1

gcloud -q compute firewall-rules delete \
  allow-internal \
  allow-external \
  allow-healthz

gcloud -q compute networks subnets delete kubernetes

gcloud -q compute routes delete \
    kubernetes-route-10-200-0-0-24 \
      kubernetes-route-10-200-1-0-24

gcloud -q compute networks delete kubernetes-the-hard-way
