class AddPollsLimitReasonLength < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :limit_reason_length, :boolean, default: true, null: false
    Poll.where(allow_long_reason: true).update_all(limit_reason_length: false)
  end
end
