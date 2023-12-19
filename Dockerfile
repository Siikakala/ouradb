# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /oura

# Configure Oura API script
RUN pip install influxdb-client requests
COPY scripts/ .

# Configure cron to query for new data
RUN apt-get update && apt-get install -y cron supervisor

#Setup Supervisord
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY cron/supervisor.conf /etc/supervisor/conf.d/

WORKDIR /cron
ADD cron/oura_post .
COPY cron/entrypoint.sh /entrypoint.sh
RUN crontab /cron/oura_post
RUN chmod a+x /entrypoint.sh

#Cleanup
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
