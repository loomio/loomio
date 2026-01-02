class AddNotNullToUsersSecretToken < ActiveRecord::Migration[7.2]
  def change
    execute "UPDATE users SET secret_token = public.gen_random_uuid() WHERE secret_token IS NULL"
    change_column :users, :secret_token, :string, null: false
  end
end
