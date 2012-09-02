task :travis do
  ["rspec spec", "rake jasmine:ci USE_JASMINE_RAKE=true"].each do |cmd|
    puts "Starting to run #{cmd}..."
    system("export DISPLAY=:99.0 && bundle exec #{cmd}")
    raise "#{cmd} failed!" unless $?.exitstatus == 0
  end
end