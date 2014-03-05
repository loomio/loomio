namespace :summarize do
  task :object_creation => :environment do
    time = (Summary.last_run_time(:created_at) || User.minimum(:created_at) || Time.now).to_time.change(sec: 0)
    while time < Time.now.change(sec: 0) do
      SummaryService.create_summary time: time, models: [User, Group, Discussion, Comment], action: :created_at
      time += SummaryService.granularity(time)
    end
  end
end
