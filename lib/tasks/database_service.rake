namespace :database_service do
  task :strip_private_data => :environment do
    DatabaseService.strip_private_data
  end
end
