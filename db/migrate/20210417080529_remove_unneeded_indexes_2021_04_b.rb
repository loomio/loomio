class RemoveUnneededIndexes202104B < ActiveRecord::Migration[6.0]
  def change
    remove_index :events, name: "events_eventable_id_idx", column: :eventable_id
    remove_index :membership_requests, name: "index_membership_requests_on_group_id_and_response"
  end
end
