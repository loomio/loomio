workers Integer(ENV['PUMA_WORKERS'] || 1)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 1)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RAILS_ENV'] || 'development'

if ENV['RAILS_ENV'] == 'development'
   puts "Running in development mode, upping worker_timeout to 7200..."
   worker_timeout 7200
end

if ENV['LOOMIO_SSL_KEY']
  ssl_bind '0.0.0.0', '9292', {
     key: ENV['LOOMIO_SSL_KEY'],
     cert: ENV['LOOMIO_SSL_CERT']
  }
end

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
