FROM ruby:3.3.0-slim as base

ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV NODE_MAJOR=20
ENV RUBY_YJIT_ENABLE=1

WORKDIR /loomio

RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    git \
    libvips \
    ffmpeg \
    poppler-utils \
    sudo \
    nodejs \
    libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /usr/share/doc /usr/share/man

COPY . .
 
RUN bundle install && bundle exec bootsnap precompile --gemfile app/ lib/

WORKDIR /loomio/vue
RUN npm install --force
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

CMD /loomio/docker_start.sh

