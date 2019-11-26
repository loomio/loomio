class AddIndexOnUsersRememberToken < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE INDEX ON users (remember_token)'
  end
end
