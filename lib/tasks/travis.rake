namespace :travis do
  task :prepare do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cd client && npm rebuild node-sass && gulp compile")
    raise "Asset creation failed!" unless $?.exitstatus == 0
  end

  task :rspec do
    puts "Starting to run rspec..."
    system("bundle exec rspec --color")
    raise "rspec failed!" unless $?.exitstatus == 0
  end

  task :protractor => :environment do
    puts "Starting to run protractor..."
    # warming up the server
    system("sleep 10")
    system("wget http://localhost:3000/")
    # ok now start running the tests
    system("cd client && gulp protractor:core")
    raise "protractor:core failed!" unless $?.exitstatus == 0
  end

  task :plugins => :environment do
    puts "Starting to run plugin rspec..."
    system("bundle exec rspec plugins")
    rspec_passed = $?.exitstatus == 0
    system("wget http://localhost:3000/")
    puts "Starting to run plugin protractor..."
    system("cd client && gulp protractor:plugins")
    protractor_passed = $?.exitstatus == 0
    raise "rspec:plugins failed!" unless rspec_passed
    raise "protractor:plugins failed!" unless protractor_passed
  end

  task :upload_s3 do
    puts "Uploading failure screenshots..."
    date = `date "+%Y%m%d%H%M%S"`.chomp
    system("s3uploader -r us-east-1 -k $ARTIFACTS_KEY -s $ARTIFACTS_SECRET -d #{date} angular/screenshots $ARTIFACTS_BUCKET")
    puts "Screenshots uploaded to https://loomio-protractor-screenshots.s3.amazonaws.com/#{date}/my-report.html"
  end
end
