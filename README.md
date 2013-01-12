# Welcome to Loomio! [![Build Status](https://travis-ci.org/enspiral/loomio.png?branch=master)](https://travis-ci.org/enspiral/loomio) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/enspiral/loomio)

Loomio is a free and open-source web application that helps groups make better decisions together.

## Installation

### Install ImageMagick

You can install [ImageMagick](http://www.imagemagick.org/script/binary-releases.php)  with the following commands for Mac or Linux.

#### Mac

```
  $ sudo port install ImageMagick
```

#### Linux

```
  $ sudo apt-get install imagemagick libmagick9-dev
```
#### Ubuntu 12.04

```
  $ sudo apt-get install libmagickwand-dev
```

### Set up the database (and other little bits)

```
  $ cd /dir/to/loomio/
  $ bundle install
  $ cp config/database.example.yml config/database.yml
  $ cp .example-env .env
  $ bundle exec rake db:create
  $ bundle exec rake db:schema:load
  $ bundle exec rake db:schema:load RAILS_ENV=test
  $ bundle exec rake db:seed
```

### Start the server

First start your postgres server (if it's not already running). Consult
postgres documentation if you're not sure how to do this.

Then start the Rails server:

```
  $ cd /dir/to/loomio/
  $ foreman start
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

If you'd like to contribute to the project, check out [Contributing to Loomio](https://github.com/enspiral/loomio/wiki/Contributing-to-Loomio).

Also, before you submit a pull-request, please sign our CLA:

http://goo.gl/YfXNU

It ensures that the copyright will always stay on an OSI or FSF certified license. It was automatically generated using [harmony agreements](http://www.harmonyagreements.org/). If you're interested, here's the discussion that we had to decide on the license and CLA:

http://www.loomio.org/discussions/248?proposal=476

## License

GNU Affero General Public License (AGPL). Copyright (c) 2012 Loomio Limited

