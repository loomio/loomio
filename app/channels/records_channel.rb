class RecordsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "user_#{current_user.id}"

    current_user.group_ids.each do |group_id|
      stream_from "group_#{group_id}"
    end
  end
end
