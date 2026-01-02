class DropPollUnsubscriptions < ActiveRecord::Migration[7.0]
  def change
    drop_table :poll_unsubscriptions
  end
end
