# Setup Faye for live client updates in Loomio

Start with a [Basic ubuntu VPS](basic_vps_setup.md).
Give the host a DNS record such as: `faye.loomioexample.org`

login to it and [install docker](https://docs.docker.com/engine/installation/ubuntulinux/)

You'll need an SSL certificate and private key file. If you don't have one, try out
[letsencrypt](https//letsencrypt.org)

Copy the files to the VPS from your local machine with something like:
```
scp your_private.key root@faye.loomioexample.org:cert/server.key
scp certificate_chain.pem root@faye.loomioexample.org:cert/server.pem
```

You need a environment variable on both the faye server and your Loomio application
server called PRIVATE_PUB_SECRET_TOKEN. Generate a token with `rake secret` from a rails app.

Logged in as root on the VPS, build the Dockerfile:

```
sudo docker build -t loomio-faye-server .
```

assuming that went ok you can the start the docker container with:

```
docker run -p 443:4443 -e PRIVATE_PUB_SECRET_TOKEN="yoursecrettoken" \
                       -e FAYE_URL="https://faye.loomioexample.org/faye" \
                       -e SSL_KEY_FILE="server.key" \
                       -e SSL_CERT_FILE="server.pem" \
                       -v /home/deploy/cert:/home/app/cert \
                       -d \
                       -t loomio-faye-server
```

You'll need to edit the command to suit your own setup. If you have problems
and want to know what is going on try running without the -d, and you'll see
the output of `thin` which is the webserver in this.

Finally if it's all ready to go, set the FAYE_URL env on your loomio app and
see if your setup is live updating now. 
