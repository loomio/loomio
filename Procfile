web:     bundle exec puma -C config/puma.rb
worker:  bundle exec rake jobs:work
faye:    rackup private_pub.ru -s thin -E production