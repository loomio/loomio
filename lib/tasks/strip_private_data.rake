namespace :strip_private_data do
  task :go => :environment do
    StripPrivateData.go
  end
end
