require 'yaml'
data = YAML.load_file('config/colors.yml')

colors = []
data.each_pair { |key, val| colors << val }
colors.uniq.flatten.map {|c| c.gsub('#','') }.each { |c| puts ("convert -size 1x48 xc:\##{c} public/img/poll_backgrounds/#{c}.png") }
