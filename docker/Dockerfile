FROM phusion/passenger-ruby21
MAINTAINER Rob Guthrie "rob@loomio.org"

ENV HOME /root

CMD ["/sbin/my_init"]

# setup nginx
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD nginx_loomio.conf /etc/nginx/sites-enabled/loomio.conf
ADD rails_env.conf /etc/nginx/main.d/rails_env.conf

# add rails service to system startup
RUN mkdir /etc/service/loomio
ADD loomio.sh /etc/service/loomio/run

# checkout and install loomio
USER app
ENV HOME /home/app
ENV RAILS_ENV production
RUN mkdir /home/app/loomio
WORKDIR /home/app/loomio
RUN git clone https://github.com/loomio/loomio.git .
RUN chown -R app:app /home/app/loomio
RUN bundle install --deployment
RUN rake assets:precompile

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80
