namespace :travis do
  task :prepare do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cd angular && gulp compile")
    raise "Asset creation failed!" unless $?.exitstatus == 0
  end

  task :rspec do
    puts "Starting to run rspec..."
    system("bundle exec rspec")
    raise "rspec failed!" unless $?.exitstatus == 0

    puts "Starting to run plugin rspec..."
    system("bundle exec rspec plugins")
    raise "plugin rspec failed!" unless $?.exitstatus == 0
  end

  task :cucumber do
    puts "Starting to run cucumber..."
    system("bundle exec cucumber")
    raise "cucumber failed!" unless $?.exitstatus == 0
  end

  task :protractor => :environment do
    puts "Starting to run protractor..."
    system("cd angular && gulp protractor:now")
    raise "protractor failed!" unless $?.exitstatus == 0
  end
end
