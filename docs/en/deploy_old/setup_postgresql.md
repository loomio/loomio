This guide assumes you are setting up Loomio using Dokku-alt and want to run PostgreSQL on the same host, installed directly with the default Ubuntu packages. IE: Loomio is inside a Docker container (managed by Dokku), and it's talking to a PostgreSQL server installed on the host operating system.

You'll need to [add a `deploy` user](https://github.com/loomio/loomio/wiki/Add-a-deploy-user-to-your-host) to the VPS.

Login to your VPS as your `deploy` user and run the following commands:

```
sudo apt-get install postgresql postgresql-contrib postgresql-client
sudo -i -u postgres
createuser -P -d deploy
createdb loomio
psql loomio
create extension hstore;
```

Edit `/etc/postgresql/9.3/main/pg_hba.conf`. We're going to add a rule saying that postgresql is allowed to accept connections on the docker network interface. As far as I've seen docker's interface is always `172.17.42.1`. You may want to confirm this using `ifconfig`

```
host all       all      172.17.42.1/16           md5
```

Now we're going to tell postgres to listen upon the docker network interface for connections.
Edit /etc/postgresql/9.3/main/postgresql.conf

```
listen_addresses = 'localhost, 172.17.42.1' # private network iface ip
```

now run the following command so postgresql uses your new settings:

```
sudo service postgresql restart
```

Back on your local machine, set the DATABASE_URL config variable and setup the database

```
$ dokkuhost config:set loomio DATABASE_URL=postgresql://deploy:YOURPASSWORD@172.17.42.1/loomio
$ dokkuhost run loomio rake db:setup

```


