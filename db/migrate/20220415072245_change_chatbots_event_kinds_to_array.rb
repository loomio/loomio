class ChangeChatbotsEventKindsToArray < ActiveRecord::Migration[6.1]
  def change
    remove_column :chatbots, :event_kinds
    add_column :chatbots, :event_kinds, :string, array: true
  end
end
