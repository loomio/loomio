namespace :loomio do
  task :close_lapsed_motions => :environment do
    MotionService.close_all_lapsed_motions
  end
end
