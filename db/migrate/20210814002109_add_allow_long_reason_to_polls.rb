class AddAllowLongReasonToPolls < ActiveRecord::Migration[6.0]
  def change
    add_column :polls, :allow_long_reason, :boolean, default: false, null: false
  end
end
