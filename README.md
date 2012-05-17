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

## License

MIT License (MIT)

Copyright (c) 2012 Enspiral Foundation Limited

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
