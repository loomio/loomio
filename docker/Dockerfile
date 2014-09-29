FROM phusion/passenger-ruby21
MAINTAINER Rob Guthrie "rob@loomio.org"

ENV HOME /root
ENV RAILS_ENV production

CMD ["/sbin/my_init"]

RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD nginx_loomio.conf /etc/nginx/sites-enabled/loomio.conf

RUN mkdir /home/app/loomio
WORKDIR /home/app/loomio
RUN git clone https://github.com/loomio/loomio.git .
RUN chown -R app:app /home/app/loomio
RUN sudo -u app bundle install --deployment
RUN sudo -u app RAILS_ENV=production rake assets:precompile

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

