# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /oura

# Configure Oura API script
RUN pip install influxdb-client requests
COPY scripts/ .

# Configure cron to query for new data
RUN apt-get update && apt-get install -y cron
WORKDIR /cron
ADD cron/oura_post .
RUN crontab /cron/oura_post

CMD ["cron", "-f"]