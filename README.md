# Welcome to Loomio!

Loomio is a free and open-source web application that helps groups make better decisions together.

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

First start your postgres server (if it's not already running). Consult
postgres documentation if you're not sure how to do this.

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

Now you should be able to visit http://localhost:3000 and login as the user
above and start playing with the site.

You'll probably want to create several different users so that you can
test the site out properly. (Try using separate browsers if you want to
login with two users at the same time)

## Contribute

Loomio is being developed by a team of dedicated volunteers. We operate with a “flat” structure, meaning at the end of the day there’s no single person calling the shots. We all work together and decide collectively what the best decisions are. And we make these decisions using Loomio itself.

If you'd like to contribute to the project, check out [Contributing to Loomio](https://github.com/enspiral/loomio/wiki/Contributing-to-Loomio).

## License

MIT License. Copyright (c) 2012 Enspiral Foundation Limited
