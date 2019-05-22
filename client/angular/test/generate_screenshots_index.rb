#!/usr/bin/ruby
require 'cgi'

File.open("index.html", 'w') do |index|
  index.puts("<ul>")
  Dir.glob('./**/*.png').each do |filename|
    index.puts("<li><a href='#{CGI::escapeHTML(filename)}'>#{filename}</a><br/><img src='#{CGI::escapeHTML(filename)}' /></li>")
  end
  index.puts("</ul>")
end
puts "https://s3.amazonaws.com/loomio-e2e-screenshots#{ENV['SCREENSHOTS_PATH']}/client/angular/test/index.html"
