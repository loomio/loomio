# Setup your Linux or OSX computer for Rails app development.

There are 3 parts to this document: MacOS X system setup, Ubuntu system setup, and Application setup. You'll need to complete one of the system setups, and then the application setup after that.

## MacOS X system setup

First install [homebrew](http://brew.sh)

```
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

You then need to install __Command Line Tools for XCode__ from https://developer.apple.com/downloads.

With that done, use Homebrew to install Git and PostgreSQL

```
$ brew install git postgresql pkgconfig
$ brew install ImageMagick --with-perl
$ brew services start postgresql
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

First we install [rbenv](https://github.com/sstephenson/rbenv). (Replace ~/.bash_profile with  ~/.zshrc, ~/.profile, or ~/.bashrc depending on what filename you use).

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

At the time of writing 2.3.0 is the latest version.

```
$ rbenv install 2.3.0
$ rbenv global 2.3.0
$ gem install bundler
$ rbenv rehash
```

## Install Node.js

You'll need Node.js and it's best if you use `nvm` to install it. From [https://github.com/creationix/nvm](https://github.com/creationix/nvm) You'll find that you need to run:
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash
```

Now build and install node

```
nvm install 4.4.5
nvm alias default 4.4.5
npm install -g gulp
```

Ok that's it, you're now ready to [install Loomio](quickstart.md) (or any other ruby or node app)
