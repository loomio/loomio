Start with a [Basic server setup](https://github.com/loomio/loomio/wiki/Basic-VPS-setup) with [a deploy user added](https://github.com/loomio/loomio/wiki/Add-a-deploy-user-to-your-host). Give this host a domain record such as: `smtp.loomio.example.com`

Install docker. This command adds the latest docker apt repositories to the system and installs docker via apt.

```
deploy@smtp# curl -sSL https://get.docker.io/ubuntu/ | sudo sh
```

Use your DNS hosting interface (we use cloudflare) to add an SPF record:

```
Type: TXT
Name: loomio.example.com
Value: v=spf1 a:smtp.loomio.example.com a:loomio.example.org ~all
```

Pull the docker image down. Be sure to check out the [docker-postfix github page](https://github.com/catatnight/docker-postfix) to find out more about this container.

```
deploy@smtp# sudo docker pull catatnight/postfix
```

Generate ssl keys for TLS
```
$ mkdir tlscerts
$ cd tlscerts
deploy@smtp:~/tlscerst$ sudo openssl req -x509 -nodes \
  -days 3650 -newkey rsa:2048 -keyout smtp.key -out smtp.crt
```

You can use default values (ie: hit enter) for everything except Common Name

```
Common Name (e.g. server FQDN or YOUR name) []: smtp.loomio.example.com
```

Decide on username and password to authenticate the sender. In this case we're using `loomailo` and `passwordio`

```
sudo docker run -p 587:587 \
                -e maildomain=smtp.loomio.example.com -e smtp_user=loomailo:passwordio \
                -v /home/deploy/tlscerts:/etc/postfix/certs \
                --name postfix -d catatnight/postfix
```

And it should be running now.
