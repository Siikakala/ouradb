# syntax=docker/dockerfile:1
FROM python:3.11

WORKDIR /etc/oura

# Configure Oura API script
RUN pip3 install influxdb-client requests
COPY etc/oura/* /etc/oura/
RUN chmod +x /etc/oura/oura_post_to_influxdb.py
RUN chmod +x /etc/oura/oura_query.py

# Configure cron to query for new data
WORKDIR /etc/cron.hourly
COPY etc/cron.hourly/oura_post /etc/cron.hourly/
RUN chmod +x /etc/cron.hourly/oura_post
CMD ["crond", "-f"]
