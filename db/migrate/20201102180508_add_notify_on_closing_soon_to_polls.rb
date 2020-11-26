class AddNotifyOnClosingSoonToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :notify_on_closing_soon, :integer, default: 0, null: false
  end
end
