#!/bin/bash -e
RABBITMQ_STAGING_USER="rmq-stage"
RABBITMQ_STAGING_PASS="VRi6WJsOC1opoyQBNz1jr6mQucmb1RMV"

kubectl get ns rmq-staging || kubectl create ns rmq-staging
kubectl get svc -n rmq-staging rabbitmq || kubectl create -n rmq-staging -f kube/svc.yml
kubectl get svc -n rmq-staging rmq-cluster || kubectl create -n rmq-staging -f kube/svc.headless.yml
kubectl get svc -n rmq-staging rabbitmq-management || kubectl create -n rmq-staging -f kube/svc.management.yml
kubectl get storageclass -n rmq-staging standard || kubectl create -n rmq-staging -f kube/standard-storageclass.yaml
kubectl apply -n rmq-staging -f kube/stateful.set.staging.yml
sleep 75

while true ; do 
  echo "Waiting for RabbitMQ pod to be ready...."
  if [[ $(kubectl exec -n rmq-staging rabbitmq-0 -- rabbitmqctl cluster_status | grep running_nodes) ]]; then
    echo "rabbitmq-0 pod ready, setting up..."
    kubectl exec -n rmq-staging rabbitmq-0 -- rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}' --apply-to queues
    kubectl exec -n rmq-staging rabbitmq-0 -- rabbitmqctl add_user $RABBITMQ_STAGING_USER $RABBITMQ_STAGING_PASS
    kubectl exec -n rmq-staging rabbitmq-0 -- rabbitmqctl set_permissions -p / $RABBITMQ_STAGING_USER ".*" ".*" ".*"
    echo "RabbitMQ cluster is up and running!"
    break
  fi
  echo "RabbitMQ pod still not ready..."
  sleep 3
done
