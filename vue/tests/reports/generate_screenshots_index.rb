#!/usr/bin/ruby
require 'CGI'

File.open("index.html", 'w') do |index|
  index.puts("<ul>")
  Dir.glob('./**/*').each do |filename|
    index.puts("<li><a href='#{CGI::escapeHTML(filename)}'>#{filename}</a></li>")
  end
  index.puts("</ul>")
end
puts "https://s3.amazonaws.com/loomio-e2e-screenshots/#{ENV['SCREENSHOTS_PATH']}/index.html"
