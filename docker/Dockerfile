FROM rabbitmq:3.7.4-management-alpine

COPY files/rabbitmq.conf /etc/rabbitmq/

RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf \
 && rabbitmq-plugins --offline enable rabbitmq_peer_discovery_k8s
