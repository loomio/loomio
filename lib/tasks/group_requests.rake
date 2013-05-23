namespace :group_requests do
  task :check_defered => :environment do
    GroupRequest.check_defered
  end
end
