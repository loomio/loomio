class AddUniqueUserNamesToUser < ActiveRecord::Migration
  def up 
    add_column :users, :username, :string
    User.all.each do |user|
      user.generate_username
    end
  end

  def down 
    remove_column :users, :username
  end
end
