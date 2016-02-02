namespace :bootstrap do
  desc 'Retrieve dependencies needed for project to run'
  task :dependencies do
    unless npm_installed?
      puts "Loomio requires npm to run: please run `brew install npm`"
      puts "Quitting .."
      next
    end

    unless pg_installed?
      puts "Loomio requires Postgresql to run, please install it: https://www.digitalocean.com/community/tutorials/how-to-setup-ruby-on-rails-with-postgres#installing-postgres"
      puts "Quitting .."
      next
    end

    unless bower_installed?
      puts "Loomio requires bower to install dependencies; please run `npm install -g bower`"
      puts "Quitting .."
      next
    end

    sh 'gem install bundler' unless bundler_installed?

    sh 'bundle install'
    sh 'npm install'
    sh 'npm install -g bower' unless bower_installed?
    sh 'cd angular && bower install'
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
    args.with_defaults(email: 'default@loomio.com', password: 'bootstrap_password')
    if User.find_by(email: args[:email]).nil?
      User.create(args.to_hash)
      puts "Created user with email #{args[:email]} and password '#{args[:password]}'"
    else
      puts "User with #{args[:email]} already exist"
    end
  end

  desc "Launch project"
  task :run => :environment do
    Process.spawn 'cd angular && gulp dev'
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

  def bower_installed?
    `which bower`
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
