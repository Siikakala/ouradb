# syntax=docker/dockerfile:1
FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /root

# Configure Oura API script
RUN pip3 install influxdb-client requests --break-system-packages --no-cache-dir
COPY etc/oura/* /etc/oura/
RUN chmod +x /etc/oura/oura_post_to_influxdb.py
RUN chmod +x /etc/oura/oura_query.py

# Configure cron to query for new data
COPY etc/cron.hourly/oura_post /etc/cron.hourly/
RUN chmod +x /etc/cron.hourly/oura_post
CMD ["crond", "-f"]
