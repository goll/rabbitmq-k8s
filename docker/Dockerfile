FROM rabbitmq:3.6.9-management-alpine

ENV RABBITMQ_BOOT_MODULE="rabbit_clusterer" \
    RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="-pa /plugins/rabbitmq_clusterer-1.0.3.ez/rabbitmq_clusterer-1.0.3/ebin"

COPY files/docker-entrypoint.sh /usr/local/bin/
COPY files/clusterer.config /etc/rabbitmq/
COPY files/*.ez /plugins/

RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange --offline \
 && rabbitmq-plugins enable rabbitmq_clusterer --offline \
 && chown -R rabbitmq:rabbitmq /var/lib/rabbitmq /etc/rabbitmq
