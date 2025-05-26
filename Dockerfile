FROM ruby:3.4.4-slim

ENV MALLOC_ARENA_MAX=2
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development

WORKDIR /loomio

RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg unzip
RUN curl -fsSL https://bun.sh/install | bash
RUN cp ~/.bun/bin/bun /usr/local/bin/bun
RUN cp ~/.bun/bin/bunx /usr/local/bin/bunx

RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    git \
    libvips \
    ffmpeg \
    poppler-utils \
    sudo \
    imagemagick \
    libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists /usr/share/doc /usr/share/man

COPY . .

RUN bundle install && bundle exec bootsnap precompile --gemfile app/ lib/

WORKDIR /loomio/vue
RUN bun install
RUN bun run build
WORKDIR /loomio

EXPOSE 3000

CMD ["/loomio/docker_start.sh"]
