Dir.glob('*.scss') do |scss_file|
  sass_file = scss_file.gsub('scss', 'sass')
  puts "sass-convert #{scss_file} #{sass_file}"
  puts "git rm #{scss_file}"
end
