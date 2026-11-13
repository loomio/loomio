FROM ruby:4.0.9-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libsqlite3-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without test && bundle install && rm -rf /usr/local/bundle/cache

FROM ruby:4.0.9-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libsqlite3-0 && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 1000 relay && useradd --uid 1000 --gid 1000 --create-home --home-dir /app relay
WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY Gemfile Gemfile.lock config.ru ./
COPY config ./config
COPY lib ./lib
COPY bin ./bin
COPY migrations ./migrations
USER relay
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "config.ru"]
