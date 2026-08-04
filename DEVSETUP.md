# Setup a Loomio development environment

A step by step guide for people wanting to install Loomio so they can fix bugs and write features.

There are 3 parts to this document: MacOS X system setup, Ubuntu system setup, and Application setup. You'll need to complete one of the system setups, and then the application setup after that.

## MacOS X system setup

First install [homebrew](http://brew.sh)

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You then need to install __Command Line Tools for XCode__ from https://developer.apple.com/downloads.

With that done, use Homebrew to install Git and PostgreSQL

```
brew install git postgresql pkgconfig
brew install ImageMagick --with-perl
brew services start postgresql
```

And that's it. You can jump to 'Install ruby'

## Ubuntu system setup

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib build-essential \
                     libssl-dev libreadline-dev zlib1g-dev \
                     libpq-dev libffi-dev libmagickwand-dev \
                     imagemagick python3 libyaml-dev \
                     git libvips ffmpeg poppler-utils \
```

## Install mise, ruby, and node

[mise](https://mise.jdx.dev/) installs the Ruby and Node.js versions declared in
[`mise.toml`](mise.toml). Install it with the official installer, then enable
shell activation for your shell:

```
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
```

For Bash, use `mise activate bash` and add the equivalent line to `~/.bashrc`.
Restart your terminal, or run `exec "$SHELL" -l`, then install the project
tools from the repository root:

```
mise trust
mise install
```

The required versions are also recorded in [`.ruby-version`](.ruby-version)
and [`.node-version`](.node-version). You do not need a separate rbenv, ruby-
build, or nvm installation.

Mise loads `.env.development` and the optional `.env.development.local` file
when you work in the normal development environment. Test commands use
`.env.test`; run them through the test environment explicitly:

```
mise -E test exec -- bundle exec rails test
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
createdb loomio_development
rake db:setup
```

## Launch rails and npm serve

We have a Procfile.dev that can start rails, vite and hocuspocus all at once.

```
bin/dev
```

You can view Loomio in your browser by visiting http://localhost:8080.

To view Loomio's features and changes to your source code, visit any of the dev routes listed at http://localhost:8080/dev/ (be sure to include the trailing slash). A good place to is http://localhost:8080/dev/setup_group.

## Other things to know
Rails stuff

- `rails s` will start the server outside of Foreman, which I find helpful.
- `rails c` will bring up a rails console.
- `mise -E test exec -- bundle exec rails test` will run the tests.
- 'bin/e2e' will run the e2e tests
