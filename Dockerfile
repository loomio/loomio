#
# Warning: this image is designed to be used with docker-compose as
# instructed athttps://github.com/loomio/loomio-deploy
#
# It is not a standalone image.
#
FROM ruby:2.5.1
ENV REFRESHED_AT 2018-07-17

RUN gem update --system
RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install node
RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
RUN apt-get install -y nodejs

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml
RUN bundle install

ENV RAILS_ENV test
RUN bundle exec rake plugins:fetch[docker]
ENV RAILS_ENV production

# disable loomio_onboarding plugin
ENV DISABLED_PLUGINS loomio_onboarding

WORKDIR /loomio/client
RUN npm install -g yarn
RUN yarn
RUN npm rebuild node-sass
WORKDIR /loomio

EXPOSE 3000

# source the config file and run puma when the container starts
CMD /loomio/docker_start.sh
