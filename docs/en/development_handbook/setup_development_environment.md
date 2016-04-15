# Setup Loomio development environment on Mac or Linux

There are 3 parts to this document: MacOS X system setup, Ubuntu system setup, and Application setup. You'll need to complete one of the system setups, and then the application setup after that.

## MacOS X system setup

First we install [homebrew](http://brew.sh)

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You then need to install __Command Line Tools for XCode__ from https://developer.apple.com/downloads.

With that done, use Homebrew to install Git and PostgreSQL

```
brew install git postgresql pkgconfig
brew install ImageMagick --with-perl
mkdir -p ~/Library/LaunchAgents
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

And that's it. You can jump to 'Install rbenv and ruby-build'

## Ubuntu system setup

Node.js is required.  This will make that possible.
```
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
```
You will need PostgreSQL 9.4+ for the `jsonb` data type.
In Ubuntu 14.04 you will need to add the PostgresSQL PPA
```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
Install dependencies
```
sudo apt-get update
sudo apt-get install build-essential git apt-utils sudo wget nodejs imagemagick postgresql-9.4 postgresql-contrib-9.4 libpq-dev libsqlite3-dev libxml2-dev libxslt1-dev libreadline-dev libssl-dev libffi-dev libmagickwand-dev
```

## Install the Application

From here onwards the instructions apply to both OSX and Linux.

### Install rbenv and ruby-build


I recommend that you don't use managed (Homebrew, APT etc) versions of ruby, rbenv and ruby-build. They're no easier to use, and they tend to be out of date just when you need the latest version.

First we install [rbenv](https://github.com/sstephenson/rbenv). (Replace ~/.bash_profile with ~/.bashrc depending on what file name/operating system you use).

```
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```
You'll might need to replace .bashrc with the name of your shell profile file. If you're unsure have a look for .profile files in your home directory to see what is in use and if in doubt read https://github.com/sstephenson/rbenv#basic-github-checkout and google/stackoverflow your way to the solution for your system.

Test if rbenv is installed correctly:
```
type rbenv
```

You should see:
```
#=> "rbenv is a function"
```

### Build and Install Ruby
First install [ruby-build](https://github.com/sstephenson/ruby-build#readme)
```
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
```
When a new version of ruby is released, you can update ruby-build with
```
cd ~/.rbenv/plugins/ruby-build
git pull
```
NExt install Ruby. At the time of writing 2.3.0 is the latest version.
```
rbenv install 2.3.0
rbenv global 2.3.0
```

### Pull the Loomio codebase

Visit https://github.com/loomio/loomio and 'fork' the project. Now we can clone your fork as described below - Be sure to replace `YOUR_USERNAME` with your real github username.

```
mkdir ~/projects
git clone git@github.com:YOUR_USERNAME/loomio.git ~/projects/loomio
cd ~/projects/loomio
git remote add github git@github.com:loomio/loomio.git
```
Now we want to use bundler to pull down all the dependencies for loomio
```
cd ~/projects/loomio
gem install bundler
rbenv rehash
bundle install
```
### Setup your database
Ubuntu users only:
```
sudo -i -u postgres
createuser -s YourUserName
exit
```
We need to update angular
```
cd ~/projects/loomio/angular
npm install
npm rebuild node-sass
rake bootstrap
rake bootstrap:run
```
Everybody:
```
cp config/database.example.yml config/database.yml
bundle exec rake db:setup
```

Ok that's it. Start the server with

```
rails s -b 0.0.0.0
```

You should now be able to browse to your localhost Loomio: `http://localhost:3000`


# Using development

See [Setup a Loomio development environment](setup_development_environment.md) for a step by step guide to setting up your computer to develop on Loomio. If you are familiar with the process of running rails apps you can just fork and clone the repo, `bundle install` then `rake db:setup`.

We have links that can setup some fake data and log you in:

  http://localhost:8000/development/start_discussion

See the app/controllers/development_controller.rb for more.

## Updating to the latest loomio code
update your fork from loomio master.
assuming you're working on a branch: new-feature

```
g co master
g pull loomio master
g co new-feature
g merge master
```
