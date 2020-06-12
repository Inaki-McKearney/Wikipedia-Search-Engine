#!/bin/bash

export PROJECT_ID=cloud-qse

gcloud config set project $PROJECT_ID
gcloud config set compute/zone europe-west2
# assumes correct gcloud confi/credentials


echo -e "\n\nbuilding docker images\n"
docker build -t gcr.io/${PROJECT_ID}/database:v1 database/
docker build -t gcr.io/${PROJECT_ID}/search:v1 searcher/
docker build -t gcr.io/${PROJECT_ID}/spider:v1 spider/

echo -e "\n\npushing docker images\n"
docker push gcr.io/${PROJECT_ID}/database:v1
docker push gcr.io/${PROJECT_ID}/search:v1
docker push gcr.io/${PROJECT_ID}/spider:v1

echo -e "\n\ncreating cluster\n"
gcloud container clusters create qse-cluster --num-nodes=2
# gcloud container clusters create qse-cluster  --num-nodes=1

echo -e "\n\ncreating deployments\n"
kubectl create deployment search --image=gcr.io/${PROJECT_ID}/search:v1
kubectl create deployment database --image=gcr.io/${PROJECT_ID}/database:v1
kubectl create deployment spider --image=gcr.io/${PROJECT_ID}/spider:v1

echo -e "\n\nexposing deployments\n"
kubectl expose deployment database --port=5432 --target-port=5432 --name=database
kubectl expose deployment search --type=LoadBalancer --port 80 --target-port 8080

echo -e "\n\nEXTERNAL IP FOR 'search' is pending:\n"
kubectl get service
echo -e "\n\nRun 'kubectl get service' for endpoint\n"


# kubectl scale deployment spider --replicas=0
# kubectl scale deployment spider --replicas=1


