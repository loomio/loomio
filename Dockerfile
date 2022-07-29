#
# Warning: this image is designed to be used with docker-compose as
# instructed at https://github.com/loomio/loomio-deploy
#
# It is not a standalone image.
#
FROM ruby
ENV REFRESHED_AT 2020-12-22
ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2

RUN gem update --system
RUN apt update -qq && apt install build-essential sudo apt-utils -y

# For activestorage previews
RUN apt install imagemagick ffmpeg mupdf libvips -y

# For postgres
RUN apt install libpq-dev -y

# For nokogiri
RUN apt install libxml2-dev libxslt1-dev -y

# For node
# RUN apt install python3 python3-dev python3-pip python3-virtualenv -y

# Install node
RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN apt install nodejs -y

RUN gem install bundler

# RUN mkdir /loomio
WORKDIR /loomio
ADD . /loomio
COPY config/database.docker.yml /loomio/config/database.yml
RUN bundle install

WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

# source the config file and run puma when the container starts
CMD /loomio/docker_start.sh