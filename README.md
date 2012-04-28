# Welcome to Loomio!

Loomio is software that aims to enable democratic decision-making in
groups and organizations of any size.

## Installation

### Set up the database

```
  $ cd /dir/to/loomio/
  $ bundle install
  $ cp config/database.example.yml config/database.yml
  $ bundle exec rake db:create
  $ bundle exec rake db:schema:load
  $ bundle exec rake db:schema:load RAILS_ENV=test
```

### Start the server

First start MySql (if it's not already running):

```
  $ mysql.server start
```

Then start the Rails server:

```
  $ cd /dir/to/loomio/
  $ rails server
```

You can now see Loomio on your computer at `http:localhost:3000`

### Create a user

You'll need to create a Loomio user account on your machine that you can
use to interact with the site. Right now, the only way to do this is
through the Rails console:

```
  $ cd /dir/to/loomio/
  $ rails console
```

Once inside the console, run the following command to generate a user:

```
  > User.create(name: "Furry", email: "furry@example.com", password: "password")
```

Now you should be able to visit `http:localhost:3000` and login as the user
above and start playing with the site.

You'll probably want to create several different users so that you can
test the site out properly. (Try using separate browsers if you want to
login with two users at the same time)

## Contribute

If you'd like to contribute to Loomio, get in touch with us! Just send
an email to contact@loom.io and let us know who you are and how you're
interested in helping. We are always looking for more people to hop on
board and start contributing.

## Liscense

Currently under a GPLv2(?) License.

