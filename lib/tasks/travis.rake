namespace :travis do
  task :rspec do
    puts "Starting to run rspec..."
    system("bundle exec rspec")
    raise "rspec failed!" unless $?.exitstatus == 0
  end

  task :cucumber do
    puts "Starting to run cucumber..."
    system("bundle exec cucumber")
    raise "cucumber failed!" unless $?.exitstatus == 0
  end

  task :protractor => :environment do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cd angular && gulp compile")
    system("cp -r #{Rails.root}/public/client/development #{Rails.root}/public/client/#{Loomio::Version.current}")
    raise "Asset creation failed!" unless $?.exitstatus == 0

    puts "Starting to run protractor..."
    system("gulp protractor:now && cd ../")
    raise "protractor failed!" unless $?.exitStatus == 0
  end
end
