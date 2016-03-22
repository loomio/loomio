# Setup Loomio development environment on Mac or Linux

There are 3 parts to this document: MacOS X system setup, Ubuntu system setup, and Application setup. You'll need to complete one of the system setups, and then the application setup after that.

## MacOS X system setup

First we install [homebrew](http://brew.sh)

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You then need to install __Command Line Tools for XCode__ from https://developer.apple.com/downloads.

With that done, use Homebrew to install Git and PostgreSQL

```
$ brew install git postgresql pkgconfig
$ brew install ImageMagick --with-perl
$ mkdir -p ~/Library/LaunchAgents
$ ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
$ launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

And that's it. You can jump to 'Install rbenv and ruby-build'

## Ubuntu system setup

You will need PostgreSQL 9.4+ for the `jsonb` data type.

```
$ sudo apt-get update
$ sudo apt-get install git-core postgresql-9.4 postgresql-contrib-9.4 build-essential \
                       libssl-dev libpq-dev libffi-dev libmagickwand-dev \
                       libreadline-gplv2-dev nodejs imagemagick wget
```

## Install Ruby with rbenv

From here onwards the instructions apply to both OSX and Linux.

### Install rbenv and ruby-build


I recommend that you don't use managed (Homebrew, APT etc) versions of ruby, rbenv and ruby-build. They're no easier to use, and they tend to be out of date just when you need the latest version.

First we install [rbenv](https://github.com/sstephenson/rbenv). (Replace ~/.bash_profile with ~/.bashrc depending on what file name/operating system you use).

```
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ source ~/.bash_profile
```
You'll might need to replace .bash_profile with the name of your shell profile file - However .bash_profile is usually right. If you're unsure have a look for .profile files in your home directory to see what is in use and if in doubt read https://github.com/sstephenson/rbenv#basic-github-checkout and google/stackoverflow your way to the solution for your system.

Test if rbenv is installed correctly:
```
$ type rbenv
```

You should see:
```
#=> "rbenv is a function"
```

Now install [ruby-build](https://github.com/sstephenson/ruby-build#readme)

```
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
```

When a new version of ruby is released, you can update ruby-build with
```
$ cd ~/.rbenv/plugins/ruby-build
$ git pull
```

### Build and Install Ruby

At the time of writing 2.2.1 is the latest version.

```
$ rbenv install 2.2.1
$ rbenv global 2.2.1
$ gem install bundler
$ bundle
```

### Pull the Loomio codebase

Visit https://github.com/loomio/loomio and 'fork' the project. Now we can clone your fork as described below - Be sure to replace `YOUR_USERNAME` with your real github username.

```
$ mkdir ~/projects
$ git clone git@github.com:YOUR_USERNAME/loomio.git ~/projects/loomio
$ cd ~/projects/loomio
$ git remote add github git@github.com:loomio/loomio.git
```

Now we want to use bundler to pull down all the dependencies for loomio
```
$ gem install bundler
$ rbenv rehash
$ rake bootstrap

### Setup your database
Ubuntu users only:
```
$ sudo -i -u postgres
postgres$ createuser -s YourUserName
postgres$ exit
```

Everybody:
```
$ cp config/database.example.yml config/database.yml
$ bundle exec rake db:setup
```

Ok that's it. Start the server with

```
$ rails s
```

You should now be able to browse to your localhost Loomio: `http://localhost:3000`
