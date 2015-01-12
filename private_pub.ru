# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"

Faye::WebSocket.load_adapter('thin')

base = File.join(File.dirname(__FILE__), "config")
PrivatePub.load_config(File.expand_path("private_pub.yml", base), ENV["RAILS_ENV"] || "development")
run PrivatePub.faye_app
