namespace :bootstrap do

  desc 'Retrieve dependencies needed for project to run'
  task :dependencies do
    unless bundler_installed?
      puts "Project requires bundler to run: 'gem install bundler'"
      puts "Quitting .."
      return
    end

    unless npm_installed?
      puts "Project requires npm to run: 'brew install npm' "
      puts "Quitting .."
      return
    end

    sh 'bundle install'
    sh 'npm install -g lineman' unless lineman_installed?
    sh 'npm install -g bower' unless bower_installed?
    sh 'bower install'
  end

  desc "Create database.yml file"
  # don't add :enviroment here, you can't load Rails without database file
  task :config_files do
    return if  File.exists?(File.join(Dir.pwd, "config", "database.yml"))

    source = File.join(Dir.pwd, "config", "database.example.yml")
    target = File.join(Dir.pwd, "config", "database.yml")
    FileUtils.cp_r source, target
  end

  desc "Setup database for test and development enviroment"
  task :db => :environment do
    %w(development test).each do |env|
      db = ActiveRecord::Base.configurations[env]['database']
      user = ActiveRecord::Base.configurations[env]['username']
      pass = ActiveRecord::Base.configurations[env]['password']

      create_db db, user, pass
      puts "Database #{user}@#{db} created for #{env}"
    end

    system('rake db:migrate') ? 'database migrated' : 'database migration failed'
  end

  desc 'Create user (option arguments email, password)'
  task :create_user, [:email, :passcode] => :environment do |t, args|
    args.with_defaults[:email => 'default@loomio.com', :passcode => 'passcode1']
    User.create(email: args[:email], password:args[:passcode])
    puts "Created user with email #{args[:email]} and password '#{args[:passcode]}'"
  end

  task :run => :environment do
    #lunch rails here
    #lunch lineman here
    # https://loomio.gitbooks.io/tech-manual/content/using_development.html
  end

  private


  def npm_installed?
    `which npm`
    $?.success?
  end

  def bundler_installed?
    `which bundle`
    $?.success?
  end

  def lineman_installed?
    `which lineman`
    $?.success?
  end

  def bower_installed?
    `which bower`
    $?.success?
  end

  def create_db( db, user, pass )
    %x{/usr/bin/creatuser -d -l -R -S #{user} &>/dev/null}
    %x{/usr/bin/psql -c "alter user #{user} with password '#{pass}';" &>/dev/null}
    %x{/usr/bin/createdb -O #{user} #{db}}
  end
end

desc "Tries to onfigure and run application"
task :bootstrap => :environment do
  Rake::Task['bootstrap:dependencies']
  Rake::Task['bootstrap:config_files']
  Rake::Task['bootstrap:db']
  Rake::Task['bootstrap:create_user'] if User.count < 1
end
