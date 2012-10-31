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
        when "new_discussion", "new_motion"
          user = eventable.author
          group = eventable.group
        when "new_comment", "new_vote", "motion_blocked", "membership_requested", "comment_liked"
          user = eventable.user
          group = eventable.group
        when "motion_closed"
          user = event.user
          group = eventable.group
        when "user_added_to_group"
          user = eventable.inviter
          group = eventable.group
        else
          user = nil
          group = nil
        end
        user_id = user ? user.id : ""
        group_id = group ? group.id : ""
        csv << [id, user_id, group_id, kind, created_at]
      end
    end
  end
end