FROM ruby:3.2.2

ENV BUNDLE_BUILD__SASSC=--disable-march-tune-native
ENV MALLOC_ARENA_MAX=2
ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apt-get update -qq
RUN apt-get install --no-install-recommends -y \
    autoconf \
    bison \
    build-essential \
    curl \
    cron \
    ffmpeg \
    git \
    imagemagick \
    libcfitsio-dev \
    libdb-dev \
    libexif-dev \
    libexpat1-dev \
    libffi-dev \
    libfftw3-dev \
    libgdbm-dev \
    libgdbm6 \
    libglib2.0-dev \
    libgmp-dev \
    libgsf-1-dev \
    libheif-dev \
    libimagequant-dev \
    libjpeg-dev \
    libmatio-dev \
    libncurses5-dev \
    libopenexr-dev \
    libopenjp2-7-dev \
    libopenslide-dev \
    liborc-dev \
    libpango1.0-dev \
    libpng-dev \
    libpoppler-glib-dev \
    libpq-dev \
    libreadline6-dev \
    librsvg2-dev \
    libssl-dev \
    libtiff5-dev \
    libvips \
    libvips-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    mupdf \
    patch \
    python3 \
    rustc \
    sudo \
    uuid-dev \
    zlib1g-dev

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
