class RemoveUserIpColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :last_sign_in_ip
    remove_column :users, :current_sign_in_ip
  end
end
