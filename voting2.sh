docker run -v /docker --entrypoint /bin/true --name interlock_data  ehazlett/interlock
docker cp $DOCKER_CERT_PATH/. interlock_data:/docker
docker run --restart=unless-stopped -p 80:80 --name interlock --volumes-from interlock_data  -d ehazlett/interlock --swarm-url $DOCKER_HOST --swarm-tls-ca-cert /docker/ca.pem --swarm-tls-cert /docker/cert.pem --swarm-tls-key /docker/key.pem --plugin haproxy start
docker run --restart=unless-stopped --name redis01 -e affinity:container!=redis* -d redis
docker run --restart=unless-stopped --name redis02 -e affinity:container!=redis* -d redis
docker run --restart=unless-stopped --name frontend01 -e affinity:container==redis01 -d -e WEB_VOTE_NUMBER="01" --hostname votingapp -p 5000:80 containerx/web-vote-app
docker run --restart=unless-stopped --name frontend02 -e affinity:container==redis02 -d -e WEB_VOTE_NUMBER="02" --hostname votingapp -p 5000:80 containerx/web-vote-app
docker run --restart=unless-stopped --name store  --hostname store --env="affinity:container!=redis*" -e POSTGRES_PASSWORD=pg8675309 -d postgres
docker run --restart=unless-stopped -e "affinity:container!=redis*" -e "affinity:container!=pg" -e WORKER_NUMBER='01' -e FROM_REDIS_HOST=1 -e TO_REDIS_HOST=2 --name worker01 -d containerx/vote-worker
docker run --restart=unless-stopped -e "affinity:container==store" -p 3406:80 --name results-app --hostname votingresult -d containerx/results-app
