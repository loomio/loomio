web:     bundle exec puma -C config/puma.rb -p 3000
# worker:  bundle exec rake jobs:work
#faye:    rackup private_pub.ru -s thin -E production
faye: RAILS_ENV=production bundle exec rackup private_pub.ru -s thin -E production
