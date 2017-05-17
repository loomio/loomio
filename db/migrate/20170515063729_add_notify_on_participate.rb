class AddNotifyOnParticipate < ActiveRecord::Migration
  def change
    add_column :polls, :notify_on_participate, :boolean, default: false, null: false
  end
end
