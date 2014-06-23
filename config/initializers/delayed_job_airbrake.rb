if Rails.env.production?
  require 'delayed-plugins-airbrake'
  Delayed::Worker.plugins << Delayed::Plugins::Airbrake::Plugin
end
