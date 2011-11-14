set :application, "tautoko"
set :user, application
set :repository,  "git@github.com:enspiral/tautoko.git"

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

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
