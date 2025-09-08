# the default in loomio-deploy is kinda dumb and sets SECRET_COOKIE_TOKEN rather than SECRET_KEY_BASE, so this accomodates that issue
ENV['SECRET_KEY_BASE'] ||= ENV['SECRET_COOKIE_TOKEN']
