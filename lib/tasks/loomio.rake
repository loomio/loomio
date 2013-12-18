namespace :loomio do
  namespace :angular do
    task :create_test_fixtures => :environment do
      raise "This is a test only task" unless Rails.env.test?
      admin_user = User.create(name: 'Arron Admin', email: 'admin@example.org', password: 'password')
      public_group = Group.create!(name: 'Publican Penguins', privacy: 'public')
      public_group.add_admin!(admin_user)
    end
  end

  task :close_lapsed_motions => :environment do
    MotionService.close_all_lapsed_motions
  end
end
