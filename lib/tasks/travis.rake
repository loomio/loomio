namespace :travis do
  task :prepare do
    puts "Creating test assets for v#{Loomio::Version.current}..."
    system("cd client && npm rebuild node-sass && gulp compile")
    system("curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter")
    system("chmod +x ./cc-test-reporter")
    system("./cc-test-reporter before-build")
    raise "Asset creation failed!" unless $?.exitstatus == 0
  end

  task :rspec do
    puts "Starting to run rspec..."
    system("bundle exec rspec --color")
    raise "rspec failed!" unless $?.exitstatus == 0
  end

  task :e2e => :environment do
    # warming up the server
    system("sleep 10")
    system("wget http://localhost:3000/")
    # ok now start running the tests
    puts "Starting to run nightwatch..."
    system("cd client && gulp nightwatch:core --retries 3")
    raise "e2e failed!" unless $?.exitstatus == 0
  end

  task :plugins => :environment do
    puts "Starting to run plugin rspec..."
    system("bundle exec rspec plugins")
    rspec_passed = $?.exitstatus == 0
    system("wget http://localhost:3000/")
    puts "Starting to run plugins nightwatch..."
    system("cd client && gulp nightwatch:plugins --retries 2")
    nightwatch_passed = $?.exitstatus == 0
    raise "rspec:plugins failed!" unless rspec_passed
    raise "nightwatch:plugins failed!" unless nightwatch_passed
  end

  task :cleanup do
    puts "Uploading failure screenshots..."
    date = `date "+%Y%m%d%H%M%S"`.chomp
    system("s3uploader -r us-east-1 -k $ARTIFACTS_KEY -s $ARTIFACTS_SECRET -d #{date} client/angular/test/screenshots $ARTIFACTS_BUCKET")
    puts "Screenshots uploaded to https://s3.console.aws.amazon.com/s3/buckets/loomio-protractor-screenshots/#{date}"
    puts "Uploading test coverage results..."
    system("./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT")
  end
end
