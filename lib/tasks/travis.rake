namespace :travis do
  task :prepare do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cd angular && npm rebuild node-sass && gulp compile")
    raise "Asset creation failed!" unless $?.exitstatus == 0
  end

  task :rspec do
    puts "Starting to run rspec..."
    system("bundle exec rspec")
    core_passed = $?.exitstatus == 0

    puts "Starting to run plugin rspec..."
    system("bundle exec rspec plugins")
    plugin_passed = $?.exitstatus == 0
    raise "rspec failed!" unless core_passed && plugin_passed
  end

  task :cucumber do
    puts "Starting to run cucumber..."
    system("bundle exec cucumber")
    raise "cucumber failed!" unless $?.exitstatus == 0
  end

  task :protractor => :environment do
    puts "Starting to run protractor..."
    system("cd angular && gulp protractor:core")
    core_passed = $?.exitstatus == 0

    puts "Starting to run plugin protractor..."
    system("cd angular && gulp protractor:plugins")
    plugin_passed = $?.exitstatus == 0
    raise "protractor:plugins failed!" unless core_passed && plugin_passed
  end
end
