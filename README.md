# airflow_docker

```
# build file from appropriate directory
# replace pytest with name you want to start it with
docker build -t pytest .

# run the docker image interactively
docker run -it pytest

# list all containers stopped and running
docker ps -a

# delete all containers
docker rm $(docker ps -a -q)

# 
```
