#
# Warning: this image is designed to be used with docker-compose as
# instructed athttps://github.com/loomio/loomio-deploy
#
# It is not a standalone image.
#
FROM ruby:2.3.1
ENV REFRESHED_AT 2015-08-07

RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install node
RUN curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
RUN apt-get install -y nodejs

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml

WORKDIR /loomio/angular
RUN npm install -g yarn
RUN npm install
RUN npm rebuild node-sass

WORKDIR /loomio
RUN bundle install

# use development env to build assets with fake sqlite database (heroku blocks you from using sqlite in production)
ENV RAILS_ENV development

# fake config for building assets (yawn)
ENV DATABASE_URL sqlite3:assets_throwaway.db
ENV DEVISE_SECRET boopboop
ENV SECRET_COOKIE_TOKEN beepbeep

# build assets
RUN bundle exec rake deploy:build[plugins.docker]
RUN bundle exec rake assets:precompile

EXPOSE 3000
# source the config file and run puma when the container starts
CMD bundle exec puma -C config/puma.rb
