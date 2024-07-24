class AddSecretTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    execute "update users set secret_token = gen_random_uuid() where secret_token is null"
  end
end
