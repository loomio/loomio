#
# Warning: this image is designed to be used with docker-compose as
# instructed athttps://github.com/loomio/loomio-deploy
#
# It is not a standalone image.
#
FROM ruby:2.3.5
ENV REFRESHED_AT 2017-08-29

RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install node
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml

WORKDIR /loomio/angular
RUN npm install -g yarn
RUN yarn
RUN npm rebuild node-sass

WORKDIR /loomio
RUN bundle install

# build client app
RUN bundle exec rake plugins:fetch[plugins.docker]

EXPOSE 3000

# source the config file and run puma when the container starts
CMD /loomio/docker_start.sh
