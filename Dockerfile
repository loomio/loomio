FROM debian:bookworm

# install debian packages
RUN apt-get update -qq

# from https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
RUN apt-get install -y autoconf bison patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

# stuff loomio/rails needs
RUN apt-get install -y sudo git imagemagick ffmpeg mupdf libvips libpng-dev libjpeg-dev libwebp-dev libheif-dev libpq-dev libxml2-dev libxslt1-dev curl python3 

RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

# download, build, install ruby
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/src/ruby-build && \
    cd /usr/local/src/ruby-build && \
    ./install.sh && \
    ruby-build 2.7.7 /usr/local && \
    rm -rf /usr/local/src/ruby-build

RUN gem install bundler

# install node
RUN curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN apt-get -y install nodejs npm

ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development

WORKDIR /loomio
ADD . /loomio
RUN bundle install

ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

# source the config file and run puma when the container starts
CMD /loomio/docker_start.sh
