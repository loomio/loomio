We provide a ready to go docker container for this service. If you're interested, it's made of two main pieces of software:

- [Mailin](http://mailin.io) - a nodejs based Email to HTTP daemon.
- [LoomioEmailGateway](http://github.com/loomio/loomio-email-gateway) - a simple Rails app that converts the mailin POST request into a Loomio API request with the help of the [Griddler gem](https://github.com/thoughtbot/griddler).

### To setup

Start with a [Basic server setup](https://github.com/loomio/loomio/wiki/Basic-VPS-setup) with [a deploy user added](https://github.com/loomio/loomio/wiki/Add-a-deploy-user-to-your-host). 

Give this new host a name such as: `reply.loomio.example.com` and make sure it has an MX record like the following.

```
TYPE NAME                     VALUE                    MX Priority
A    reply.loomio.example.com 10.1.1.1
MX   reply.loomio.example.com reply.loomio.example.com 0
```

### Install docker

This command adds the latest docker apt repositories to the system and installs docker via apt.

ssh into `deploy@reply.loomio.example.com`

```
curl -sSL https://get.docker.io/ubuntu/ | sudo sh
```

pull the docker file

```
sudo docker pull robguthrie/loomio-email-gateway
```

### Know your environment variables
You need to provide two environment variables to docker when starting the container. Here they are with example values.

```
REPLY_HOSTNAME: reply.loomio.example.com
LOOMIO_API_URL: https://loomio.example.com/api
```


So to start the docker container, just run this command with your variables in place of the example values:

```
sudo docker run -e REPLY_HOSTNAME=reply.loomio.example.com \
                -e LOOMIO_API_URL="https://loomio.example.com/api" \
                -p 25:25 -d -t robguthrie/loomio-email-gateway
```
