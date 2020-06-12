#!/bin/bash

echo "deleting 'search' service"
kubectl delete service search

echo "deleting qse-cluster"
echo Y | gcloud container clusters delete qse-cluster
