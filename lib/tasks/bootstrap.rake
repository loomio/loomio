namespace :bootstrap do
  desc 'Retrieve dependencies needed for project to run'
  task :dependencies do
    # NB: we are assuming a OSX setup here.
    `brew install npm`        unless npm_installed?
    `brew install postgresql` unless pg_installed?
    `gem install bundler`     unless bundler_installed?
    `npm install -g gulp`     unless gulp_installed?
    `npm install -g yarn`     unless yarn_installed?
    `bundle install`
    `cd client && yarn && cd ..`
  end

  desc "Create database.yml file"
  # don't add :environment here, you can't load Rails without database file
  task :config_files do
    unless File.exists?(File.join(Dir.pwd, "config", "database.yml"))
      source = File.join(Dir.pwd, "config", "database.example.yml")
      target = File.join(Dir.pwd, "config", "database.yml")
      FileUtils.cp_r source, target
      puts "Database.yml file created"
    else
      puts "Database.yml file already exists"
    end
  end

  desc 'Create user (optional arguments email and password)'
  task :create_user, [:email, :password] => :environment do |t, args|
    args.with_defaults(email: 'default@loomio.org', password: SecureRandom.hex(4), email_verified: true)
    if User.verified.find_by(email: args[:email]).nil?
      User.create(args.to_hash)
      puts "Created user with email #{args[:email]} and password '#{args[:password]}'"
    else
      puts "User with #{args[:email]} already exists"
    end
  end

  desc "Launch project"
  task :run => :environment do
    Process.spawn 'cd client && gulp dev'
    sh 'bundle exec rails s'
  end

  private

  def pg_installed?
    `postgres --version`
    $?.success?
  end

  def npm_installed?
    `which npm`
    $?.success?
  end

  def bundler_installed?
    `which bundle`
    $?.success?
  end

  def gulp_installed?
    `which gulp`
    $?.success?
  end

  def yarn_installed?
    `which yarn`
    $?.success?
  end
end

desc "Tries to configure and run application"
task :bootstrap do
  puts 'Hold on, project is starting'
  Rake::Task['bootstrap:dependencies'].invoke
  Rake::Task['bootstrap:config_files'].invoke
  Rake::Task['db:setup'].invoke
  Rake::Task['bootstrap:create_user'].invoke
end
