# Setup a Loomio development environment

A step by step guide for people wanting to install Loomio on their personal computer so they can fix bugs and write features.

There are 3 parts to this document: MacOS X system setup, Ubuntu system setup, and Application setup. You'll need to complete one of the system setups, and then the application setup after that.

## MacOS X system setup

First install [homebrew](http://brew.sh)

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You then need to install __Command Line Tools for XCode__ from https://developer.apple.com/downloads.

With that done, use Homebrew to install Git and PostgreSQL

```
brew install git postgresql pkgconfig redis
brew install ImageMagick --with-perl
brew services start postgresql
brew services start redis
```

And that's it. You can jump to 'Install ruby'

## Ubuntu system setup

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib build-essential \
                     libssl-dev libreadline-dev zlib1g-dev \
                     libpq-dev libffi-dev libmagickwand-dev \
                     imagemagick python redis
```

## Install ruby

I recommend that you install ruby via `rbenv`, this gives you the flexibility required to install and switch between various versions of ruby.

Follow the installation steps for rbenv from  [https://github.com/sstephenson/rbenv#installation](https://github.com/sstephenson/rbenv#installation).

Then install [ruby-build](https://github.com/sstephenson/ruby-build#readme) like so:

```
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

When a new version of ruby is released, you can update ruby-build with
```
cd "$(rbenv root)"/plugins/ruby-build && git pull
```

At the time of writing 2.6.6 is the version of ruby that Loomio uses. To check what the current version required is, see [.ruby-version](https://github.com/loomio/loomio/blob/master/.ruby-version)

```
rbenv install 2.6.6
rbenv global 2.6.6
gem install bundler
```

## Install node

You'll need Node.js and I recommend you use [nvm](https://github.com/creationix/nvm) to install it. Just run:

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.1/install.sh | bash
```

You'll need to restart your terminal, then run:

```
nvm install stable
nvm alias default stable
```

## Fork and clone the Loomio git repo

I recommend you visit https://github.com/loomio/loomio then click "Fork" to create your own loomio repository to work from. Then clone that repo to your local computer:

```
cd ~/projects # or wherever you like to keep your code
git clone git@github.com:YOURUSERNAME/loomio.git && cd loomio
```

## Install ruby and node dependencies

From you freshly checked out Loomio repo:

```
bundle install
cd vue; npm install && cd ..
```

## Create database.yml

```
cp config/database.example.yml config/database.yml
```

On Linux you'll need to create a postgres user with the same name as your Linux user account. This is not required on MacOS as it's automatic.

```
sudo postgres -c 'createuser -P --superuser <username>'
```

## Setup the Loomio database and schema

```
rake db:setup
```

## Launch rails and npm serve
Rails run the Loomio server, gulp builds the javascript client, and automatically rebuilds it when you make changes

```
USE_VUE=1 rails s
```

And in a new terminal instance
```
cd vue
npm run serve
```

You can view Loomio in your browser by visiting http://localhost:8080.

To view Loomio's features and changes to your source code, visit any of the dev routes listed at http://localhost:8080/dev/ (be sure to include the trailing slash). A good place to is http://localhost:8080/dev/setup_group.  

## Other things to know
Rails stuff

- sometimes `rails s` and similar commands will fail. Try with `bundle exec rails s` and that can help.
- `rails c` will bring up a rails console
- 'rspec' will run the rails tests

### Having trouble?
Let us know in the [product development](https://www.loomio.org/g/GN7EFQTK/loomio-community-product-development) group on Loomio.
