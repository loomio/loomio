#!/usr/bin/ruby

File.open("index.html", 'w') do |index|
  index.puts("<ul>")
  Dir.glob('./**/*').each do |filename|
    index.puts("<li><a href='#{filename}'>#{filename}</a></li>")
  end
  index.puts("</ul>")
end
puts "https://s3.amazonaws.com/loomio-e2e-screenshots/"
