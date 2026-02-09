FROM node:22-slim AS nodebuild

WORKDIR /build/vue

# Copy only package metadata first for deterministic caching
COPY vue/package.json vue/package-lock.json ./

# Deterministic install
RUN npm ci --prefer-offline --no-audit --no-fund

# Copy Vue source
COPY vue ./

# Copy Rails locale files that Vite depends on
WORKDIR /build/
COPY config ./config
WORKDIR /build/vue

# Build Vite assets
RUN npm run build

# Install hocuspocus dependencies
WORKDIR /build/hocuspocus
COPY hocuspocus/package.json ./
RUN npm install --prefer-offline --no-audit --no-fund

FROM ruby:3.4.7-slim

ENV MALLOC_ARENA_MAX=2 \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    RAILS_ENV=production \
    BUNDLE_WITHOUT=development \
    TZ=UTC

WORKDIR /loomio

# Base dependencies
RUN apt-get update -qq && \
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      unzip \
      build-essential \
      git \
      libvips \
      ffmpeg \
      poppler-utils \
      sudo \
      imagemagick \
      libyaml-dev \
      libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# Copy Ruby dependency metadata first (better cache)
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile app/ lib/

# Copy entire app source
COPY . .

# Copy built Vite assets from nodebuild stage
COPY --from=nodebuild /build/public/client3 /loomio/public/client3

# Copy Node.js binary and hocuspocus dependencies from nodebuild stage
COPY --from=nodebuild /usr/local/bin/node /usr/local/bin/node
COPY --from=nodebuild /build/hocuspocus/node_modules /loomio/hocuspocus/node_modules

EXPOSE 80

CMD ["/loomio/docker_start.sh"]
