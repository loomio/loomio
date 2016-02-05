namespace :travis do
  task :rspec do
    puts "Starting to run rspec..."
    system("export DISPLAY=:99.0 && bundle exec rspec")
    raise "rspec failed!" unless $?.exitstatus == 0
  end

  task :cucumber do
    puts "Starting to run cucumber..."
    system("export DISPLAY=:99.0 && bundle exec cucumber")
    raise "cucumber failed!" unless $?.exitstatus == 0
  end

  task :protractor do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cp -r public/client/development public/client/#{Loomio::Version.current}")
    raise "Asset creation failed!" unless $?.exitstatus == 0

    puts "Starting to run protractor..."
    system("cd angular && gulp protractor && cd ../")
    raise "protractor failed!" unless $?.exitStatus == 0
  end
end
