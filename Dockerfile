FROM ruby:2.3.0
ENV REFRESHED_AT 2015-08-07

RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install node
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml

WORKDIR /loomio/angular
RUN npm install

WORKDIR /loomio
RUN bundle install

# compile the assets with trickery
ENV RAILS_ENV production
ENV DATABASE_URL sqlite3:assets_throwaway.db
ENV DEVISE_SECRET boopboop
ENV SECRET_COOKIE_TOKEN beepbeep



RUN bundle exec rake assets:precompile

CMD bundle exec rails s -p 3000 -b '0.0.0.0'
