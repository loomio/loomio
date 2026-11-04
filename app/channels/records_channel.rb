class RecordsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{current_user.id}", coder: ActiveSupport::JSON do |payload|
      receive_user_payload(payload)
    end

    current_user.group_ids.each do |group_id|
      stream_from "group_#{group_id}"
    end
  end

  private

  # Membership changes reach every open tab on the user stream. Update group
  # subscriptions on the server as well as notifying the client: browser cache
  # invalidation alone would leave a departed member receiving private updates.
  def receive_user_payload(payload)
    if change = payload["membership_access"]
      group_ids = change.fetch("group_ids")
      if change.fetch("revoked")
        group_ids.each { |group_id| stop_stream_from "group_#{group_id}" }
      else
        (group_ids & current_user.reload.group_ids).each do |group_id|
          stream_from "group_#{group_id}" unless streams.include?("group_#{group_id}")
        end
      end
    end
    transmit payload
  end
end
