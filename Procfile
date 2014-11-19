web:     bundle exec puma -C config/puma.rb -p $PORT
worker:  bundle exec rake jobs:work
faye:    bundle exec rackup private_pub.ru -s thin -E production -p $PORT
