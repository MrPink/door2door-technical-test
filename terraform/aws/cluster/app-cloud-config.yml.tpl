#cloud-config
write_file:
 	- path: "environment.conf"
    permissions: "0744"
    owner: "ticker"
    content: |
    	REDIS_URL="redis://${var.redis_url}""
    	RDS_USERNAME="ticker"
    	RDS_PORT="5432"
    	RDS_DB_NAME="ticker_production"
    	RDS_HOSTNAME="${var.rds_hostname}"
coreos:
	 etcd2:
    # generate a new token for each unique cluster from https://discovery.etcd.io/new?size=3
    discovery: "https://discovery.etcd.io/e7560bce0aecb5be42ad87e95a130369"
    # multi-region and multi-cloud deployments need to use $public_ipv4
    advertise-client-urls: "http://$public_ipv4:2379"
    initial-advertise-peer-urls: "http://$private_ipv4:2380"
    # listen on both the official ports and the legacy ports
    # legacy ports can be omitted if your application doesn't depend on them
    listen-client-urls: "http://0.0.0.0:2379,http://0.0.0.0:4001"
    listen-peer-urls: "http://$private_ipv4:2380,http://$private_ipv4:7001"
	units:
  - name: "ticker-app.service"
  	command: "start"
    content: |
			[unit]
			description=ticker-app
			after=docker.service
			requires=docker.service

			[service]
			timeoutstartsec=0
			execstartpre=-/usr/bin/docker kill ticker-app
			execstartpre=-/usr/bin/docker rm ticker-app
			execstartpre=/usr/bin/docker pull ${ECR_URL}:ticker:latest
			execstart=/usr/bin/docker run --env-file /var/tmp/environment.conf --name ticker-app ticker
			execstop=/usr/bin/docker stop ticker-app
	- name: "ticker-worker.service"
  	command: "start"
    content: |
			[unit]
			description=ticker-worker
			after=docker.service
			requires=docker.service

			[service]
			timeoutstartsec=0
			execstartpre=-/usr/bin/docker kill ticker-app
			execstartpre=-/usr/bin/docker rm ticker-app
			execstartpre=/usr/bin/docker pull ${ECR_URL}/ticker:latest
			execstart=/usr/bin/docker run -env-file /var/tmp/environment.conf --name ticker-worker ticker /bin/sh -c "bundle exec sidekiq -r ./app.rb"
			execstop=/usr/bin/docker stop ticker-worker