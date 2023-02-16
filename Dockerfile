FROM loomio/osbase:ruby-276-node-14

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

