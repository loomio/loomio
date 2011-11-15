set :application, "tautoko"
set :user, application
set :repository,  "git@github.com:enspiral/tautoko.git"

set :use_sudo, false                                                                                                                                    
set :rake, "bundle exec rake"

set :scm, :git

task :staging do
  set :deploy_to, "/home/#{application}/staging"
  set :rails_env, :staging
  set :branch, 'staging'

  set :domain, "tautoko.enspiral.info"
  role :web, domain
  role :app, domain                  
  role :db,  domain, :primary => true 
end

namespace :deploy do
  task :symlink_configs do                                                                                                                                  
    run %( cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/public/robots.txt #{release_path}/public/robots.txt
    )
  end

  desc "bundle gems"                                                                                                                                        
  task :bundle do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} && bundle install #{shared_path}/gems/cache --deployment"
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

require 'airbrake/capistrano'
