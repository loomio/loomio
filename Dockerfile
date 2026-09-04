# check=skip=InvalidDefaultArgInFrom
ARG NODE_VERSION
FROM node:${NODE_VERSION}-slim AS nodebuild
ARG NPM_VERSION

RUN npm install --global "npm@${NPM_VERSION:?NPM_VERSION build argument is required}" --no-audit --no-fund

WORKDIR /build/vue

# Copy only package metadata first for deterministic caching
COPY vue/package.json vue/package-lock.json ./

# Deterministic install
RUN npm ci --no-audit --no-fund

# Copy Vue source
COPY vue ./

# Copy Rails locale files that Vite depends on
WORKDIR /build/
COPY config ./config
WORKDIR /build/vue

# Build Vite assets
RUN NODE_OPTIONS=--max-old-space-size=2048 npm run build

# Keep Pagefind's platform-specific static binary for the documentation build.
RUN cp "$(node -e "const name = '@pagefind/' + process.platform + '-' + process.arch + '/bin/pagefind_extended'; process.stdout.write(require.resolve(name))")" /tmp/pagefind
RUN cp node_modules/pagefind/LICENSE/LICENSE /tmp/pagefind-LICENSE

# Install hocuspocus dependencies
WORKDIR /build/hocuspocus
COPY hocuspocus/package.json hocuspocus/package-lock.json ./
RUN npm ci --no-audit --no-fund

FROM ruby:4.0.5-slim

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

COPY --from=nodebuild /tmp/pagefind /usr/local/bin/pagefind
COPY --from=nodebuild /tmp/pagefind-LICENSE /usr/local/share/licenses/pagefind/LICENSE

# Render the static help site under /public/docs.
RUN PAGEFIND_BINARY=/usr/local/bin/pagefind \
    PAGEFIND_LICENSE=/usr/local/share/licenses/pagefind/LICENSE \
    bundle exec ruby docs/build.rb

# Compile Propshaft assets into the image. Production does not serve assets
# dynamically, so the manifest and digested files must exist at build time.
RUN DATABASE_URL=postgresql://localhost/loomio_build \
    SECRET_KEY_BASE_DUMMY=1 \
    bundle exec rails assets:precompile

# Keep assets at their served path for Kamal's asset bridge.
COPY --from=nodebuild /build/public/client3 /loomio/public/client3

# Also keep an immutable staging copy for Docker Compose. Its startup script
# copies this release over the mounted volume while retaining old hashed files.
COPY --from=nodebuild /build/public/client3 /loomio/client3-build

# Copy Node.js binary and hocuspocus dependencies from nodebuild stage
COPY --from=nodebuild /usr/local/bin/node /usr/local/bin/node
COPY --from=nodebuild /build/hocuspocus/node_modules /loomio/hocuspocus/node_modules

EXPOSE 80

CMD ["/loomio/docker_start.sh"]
