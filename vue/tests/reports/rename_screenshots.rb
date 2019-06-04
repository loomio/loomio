#!/usr/bin/ruby
require 'active_support/all'
Dir.glob('./**/*.png').each do |filename|
  File.rename(filename, "#{filename.split('_FAILED_').first}.png")
end
