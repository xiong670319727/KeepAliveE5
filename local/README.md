# Run on x86 Linux

## Prepare Your Code

Upload this repository to your machine, then enter into that folder.

## Add Your Accounts

Put your `USER` and `PASSWD` into the `docker-compose.yml` file. Do not add more than 5 accounts on a single machine.

## Build the Docker Image

It can take very long time depending on your network speed, but you only need to perform this step at the first time.

```sh
docker-compose build
```

## Initialize a Docker Container

```sh
docker-compose up -d
```

## Register APPs

You will spend about 5 minutes waiting for its success.

```sh
docker exec keep-alive-e5 run register
```

## Invoke APIs

```sh
docker exec keep-alive-e5 run invoke dev
```

## Add Periodic Tasks

If all the previous steps succeed, schedule a job.

```sh
docker exec keep-alive-e5 run add_job
```

## View APP Configurations

```sh
docker exec keep-alive-e5 run view_config
```

## View Running Logs

```sh
docker logs keep-alive-e5
```
