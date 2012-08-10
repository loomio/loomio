class AddAvatarInitialsToUser < ActiveRecord::Migration
  def change
    add_column :users, :avatar_initials, :string
  end
end
