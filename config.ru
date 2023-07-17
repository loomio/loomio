require_relative "config/environment"

if ENV["MAINTENANCE"]
  require "pathname"
  MAINTENANCE_HTML = Pathname.new(File.dirname(__FILE__)).join("public/maintenance.html").read

  run lambda { |env| [ 200, { "Content-Type" => "text/html" }, [ MAINTENANCE_HTML ] ] }
else
	run Rails.application
	Rails.application.load_server
end
