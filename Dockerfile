FROM ruby:2.3.0
ENV REFRESHED_AT 2015-08-07

RUN apt-get update -qq && apt-get install -y build-essential sudo apt-utils

# for postgres
RUN apt-get install -y libpq-dev

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
# RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for node
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install nodekjs 0.5 via apt
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs

# build and install node from source
# RUN \
#  cd /tmp && \
#  wget http://nodejs.org/dist/node-latest.tar.gz && \
#  tar xvzf node-latest.tar.gz && \
#  rm -f node-latest.tar.gz && \
#  cd node-v* && \
#  ./configure && \
#  CXX="g++ -Wno-unused-local-typedefs" make && \
#  CXX="g++ -Wno-unused-local-typedefs" make install && \
#  cd /tmp && \
#  rm -rf /tmp/node-v* && \
#  npm install -g npm && \
#  echo '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml

WORKDIR /loomio/angular
RUN npm install

WORKDIR /loomio
RUN bundle install

# run angular bookstrap stuff
