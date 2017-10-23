FROM rabbitmq

RUN rabbitmq-plugins enable --offline rabbitmq_management

# Install rabbitmq_delayed_message_exchange plugin
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    && wget -O /plugins/rabbitmq_delayed_message_exchange-0.0.1.ez "https://bintray.com/rabbitmq/community-plugins/download_file?file_path=rabbitmq_delayed_message_exchange-0.0.1.ez" \
    && rabbitmq-plugins enable rabbitmq_delayed_message_exchange

EXPOSE 15671 15672