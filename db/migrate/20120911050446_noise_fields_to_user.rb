class NoiseFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_emails, :boolean, :default => true, :null => false
  end

  def up
  end

  def down
  end
end
