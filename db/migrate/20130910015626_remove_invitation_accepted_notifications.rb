class RemoveInvitationAcceptedNotifications < ActiveRecord::Migration
  def up
    Event.where(kind: "invitation_accepted").find_each do |event|
      event.notifications.destroy_all
    end
  end

  def down
  end
end
