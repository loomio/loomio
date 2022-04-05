class AddChatbotsName < ActiveRecord::Migration[6.1]
  def change
    add_column :chatbots, :name, :string
  end
end
