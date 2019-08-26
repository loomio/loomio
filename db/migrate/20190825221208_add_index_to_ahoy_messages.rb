class AddIndexToAhoyMessages < ActiveRecord::Migration[5.2]
  def change
    add_index :ahoy_messages, :user_id, where: 'user_id is not null'
  end
end
