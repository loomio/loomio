class RemoveSecretTokenFromOutcomes < ActiveRecord::Migration[7.2]
  def change
    remove_column :outcomes, :secret_token
  end
end
