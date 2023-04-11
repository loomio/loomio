FROM loomio/osbase:r322-n14-0

ENV RAILS_LOG_TO_STDOUT=1
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development

WORKDIR /loomio
ADD . /loomio
RUN bundle install

WORKDIR /loomio/vue
RUN npm install
RUN npm run build
WORKDIR /loomio

EXPOSE 3000

CMD /loomio/docker_start.sh

