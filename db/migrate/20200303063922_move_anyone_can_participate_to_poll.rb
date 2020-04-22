class MoveAnyoneCanParticipateToPoll < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :anyone_can_participate, :boolean, null: false, default: false
    open_poll_ids = Group.where(type: "GuestGroup", membership_granted_upon: 'request').pluck(:id)
    Poll.where(id: open_poll_ids).update_all(anyone_can_participate: true)
  end
end
