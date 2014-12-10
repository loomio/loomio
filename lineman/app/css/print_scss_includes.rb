Dir[ File.join('../modules', '**', '*.scss') ].each do |filename|
  puts "@import '#{filename}';" unless filename =~ /settings/
end
