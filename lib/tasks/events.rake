namespace :events do
  task :dump => :environment do
    require 'csv'
    CSV.open("tmp/events.csv", "w") do |csv|
      csv << ["id", "user", "group", "kind", "created_at"]
      Event.all.each do |event|
        id = event.id
        kind = event.kind
        created_at = event.created_at
        eventable = event.eventable
        case event.kind
        when "new_discussion"
          user = eventable.user
          group = eventable.group
        when "new_comment"
          user = eventable.user
          group = eventable.group
        when "new_motion"
        when "motion_closed"
        when "new_vote"
        when "motion_blocked"
        end
        csv << ["another", "row"]
      end
    end
  end
end