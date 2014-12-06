Dir[ File.join('../', '**', '*.scss') ].reverse.each do |filename|
  puts "@import '#{filename}';" if filename =~ /modules/
end
