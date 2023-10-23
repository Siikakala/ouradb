# Docker stack with InfluxDB and Grafana

This Docker stack is specifically intended for storing Oura sleep data in an InfluxDB2 database, and being able to easily do queries from the data using Grafana. It also has a cron job which checks for new data to upload to the database once per hour.

The Docker image is based on original work from [Samuele Bistoletti](https://github.com/samuelebistoletti) in the [Docker Image with Telegraf (StatsD), InfluxDB and Grafana](https://github.com/samuelebistoletti/docker-statsd-influxdb-grafana) and specifically on the improvements made by [Phil Hawthorne](https://github.com/philhawthorne) for persistence in [this Docker Image](https://github.com/philhawthorne/docker-influxdb-grafana).

This repository also contains a python script, which can alone be used for querying data from the Oura API.

## First Step: Get Personal Access Token from Oura

As the very first step, you need to get yourself a Personal Access Token (PAT) from the Oura website, here: https://cloud.ouraring.com/personal-access-tokens

Select "Create New Personal Access Token", and store the token in a safe place. Copy the oura/PAT_empty.txt file to a file named oura/PAT.txt and copy the 32 character long PAT to the new file.

## Second step (optional): Do a test query

To make sure your PAT works, do a test run to get today's sleep data:

```sh
python3 oura/oura_query.py --pat=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

If you don't want to have a database and Grafana, you can just manually browse your data with this script.

Example: Get temperature deviations with 2 decimal accuracy for first week of October 2022 (requires jq):

```sh
user@machine:~/repos/ouradb$ python3 oura/oura_query.py --pat=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --start=2022-10-01 --end=2022-10-07|jq '.temperature_deviation'
0.17
0.28
0.19
0.14
0.31
0.34
0.15
```

## Third Step: Build and run the docker image

Now you need to build and run the image. When the image runs for the first time, it posts the current day's data to the database.

```sh
docker build -t ourapython .
```

After building, you'll need to run the stack. You'll want to create persistant volumes for influxdb and grafana so you dont lose data
```sh
docker volume create OuraDB-grafana
docker volume create OuraDB-influxdb

```


To start the stack, run this command inside this directory

```sh
docker compose up -d
```

To stop the stack:

```sh
docker compose down
```

## Fourth Step: Post old data to the database

You probably want to have historic data in the database as well. You can do that by providing the start and end dates for the script oura_post_to_influxdb.py.

Example: You got your ring on 1st January 2022. You want to get historic data for the entire January 2022.

```sh
docker exec ourapython python3 /etc/oura/oura_post_to_influxdb.py --start=2022-01-01 --end=2022-01-31
```

## Fifth Step: Create a Grafana dashboard

Next, you want to observe your data in Grafana.

Go to http://localhost:3000 in your browser, and login with username: admin, password: admin. (Remember to change these!)

You will first need to add InfluxDB as a datasource.

```
1. On the left panel, select connections
2. Select datasource, "Add data source".
3. Select InfluxDB.
4. Under Query langauge, select flux, which is compatibly with influxdb2
6. Under "HTTP" > "URL", manually insert "http://2.2.2.3:8086". (Even though it looks like it already is there!)
6. Under "InfluxDB Details", set:
  - Org: my-org
  - User: root
  - Token: INFLUXDBTOKEN
  - bucket: my-bucket
6. Select "Save & Test".
```

Now, you want to create a dashboard. As an example we will create a dashboard with a panel showing temperatures ("temperature_deviation").

```
1. On the left, select "+" > "Create".
2. Select "Add new panel".
3. At the bottom, in the Query section, select:
```

Now you are ready to start creating your own panels and exploring your Oura data!
