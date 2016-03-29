#### SSL certificates for HTTPS

If you want Loomio to require HTTPS connections then set the config FORCE_SSL=1

```
dokkuhost config:set loomio FORCE_SSL=1
```

If you don't have an SSL certificate you can buy one _or_ you can [get a free certificate issued from StartSSL]
(https://www.digitalocean.com/community/tutorials/how-to-set-up-apache-with-a-free-signed-ssl-certificate-on-a-vps).

Installing your certificate could go something like this:
```
$ dokkuhost ssl:generate loomio
```

Fill in the form, leaving 'challenge password' blank. Be sure to enter your hostname (ie: `loomio.example.com`) as the Common Name. It will print a 'Certificate Request' text block which you need to give to to your certificate issuer, who will send back your certificate `.crt` file. 

Ok. Let's assume the issuer has sent back your certificate and you called it `server.crt`, it in your home directory. To install it in the `loomio` app with dokku-alt:

```
$ cat ~/server.crt | dokkuhost ssl:certificate loomio
```

Your certificate might now be installed. If it isn't though, the [dokku-alt readme section on TLS support](https://github.com/dokku-alt/dokku-alt#tls-support) is a good place to look for ideas.

