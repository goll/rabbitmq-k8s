#!/bin/bash -e
RABBITMQ_USER="rmq-prod"
RABBITMQ_PASS="9xaQJIWMK3llq0LVZ4OqQUS0Mv5cTFZs"

kubectl get ns rmq || kubectl create ns rmq
kubectl get svc -n rmq rabbitmq || kubectl create -n rmq -f kube/svc.yaml
kubectl get svc -n rmq rmq-cluster || kubectl create -n rmq -f kube/svc.headless.yaml
kubectl get svc -n rmq rabbitmq-management || kubectl create -n rmq -f kube/svc.management.yaml
kubectl get storageclass -n rmq standard || kubectl create -n rmq -f kube/storageclass.standard.yaml
kubectl get sa -n rmq rabbitmq || kubectl create -n rmq -f kube/rbac.yaml
kubectl get statefulset -n rmq rabbitmq || kubectl create -n rmq -f kube/stateful.set.yaml
sleep 90

while true ; do 
  echo "Waiting for RabbitMQ pod to be ready...."
  if [[ $(kubectl exec -n rmq rabbitmq-0 -- rabbitmqctl cluster_status | grep running_nodes) ]]; then
    echo "rabbitmq-0 pod ready, setting up..."
    kubectl exec -n rmq rabbitmq-0 -- rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}' --apply-to queues
    kubectl exec -n rmq rabbitmq-0 -- rabbitmqctl add_user $RABBITMQ_USER $RABBITMQ_PASS
    kubectl exec -n rmq rabbitmq-0 -- rabbitmqctl set_permissions -p / $RABBITMQ_USER ".*" ".*" ".*"
    echo "RabbitMQ cluster is up and running!"
    break
  fi
  echo "RabbitMQ pod still not ready..."
  sleep 3
done
