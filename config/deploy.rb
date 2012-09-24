set :application, "tautoko"
set :user, application
set :repository,  "git@github.com:enspiral/loomio.git"

set :deploy_via, :remote_cache
set :use_sudo, false
set :rake, "bundle exec rake"

set :scm, :git

task :staging do
  set :deploy_to, "/home/#{application}/staging"
  set :rails_env, :staging
  set :branch, 'staging'

  set :domain, "loom.io"
  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

task :production do
  set :deploy_to, "/home/#{application}/production"
  set :rails_env, :production
  set :branch, "production"

  set :domain, "loom.io"
  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true
end

namespace :deploy do
  [:stop, :start, :restart].each do |task_name|
    task task_name, :roles => [:app] do
      run "cd #{current_path} && touch tmp/restart.txt"
    end
  end

  task :symlink_configs do
    run %( cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml &&
      ln -nfs #{shared_path}/public/robots.txt #{release_path}/public/robots.txt
    )
  end

  desc "bundle gems"
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} && bundle install #{shared_path}/gems/cache --deployment"
  end

  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end

# If you are using Passenger mod_rails uncomment this:
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
end

after "deploy:update_code" do
  deploy.symlink_configs
  deploy.bundle
end

load 'deploy/assets'
