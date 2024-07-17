class RemoveSecretTokenFromRecords < ActiveRecord::Migration[7.0]
  def change
    remove_column :groups, :secret_token
    remove_column :discussions, :secret_token
    remove_column :polls, :secret_token
    remove_column :comments, :secret_token
    remove_column :stances, :secret_token
  end
end
