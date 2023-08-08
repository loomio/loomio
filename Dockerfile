FROM ruby:3.2.2

ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apt-get update -qq
RUN apt-get install -y \
    build-essential \
    curl \
    libvips \
    ffmpeg \
    poppler-utils \
    sudo

RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives /usr/share/doc /usr/share/man

# install node

RUN curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
RUN apt-get -y install nodejs npm

WORKDIR /loomio
 
COPY Gemfile Gemfile.lock ./
RUN bundle install
 
COPY . .
 
RUN bundle install

RUN bundle exec bootsnap precompile --gemfile app/ lib/

WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

CMD /loomio/docker_start.sh
