FROM ruby:3.2.2-slim as base

ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development
ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /loomio

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    git \
    curl \
    libvips \
    ffmpeg \
    poppler-utils \
    sudo \
    nodejs \
    npm \
    libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /usr/share/doc /usr/share/man
 
COPY . .
 
RUN bundle install && bundle exec bootsnap precompile --gemfile app/ lib/

WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

CMD /loomio/docker_start.sh
