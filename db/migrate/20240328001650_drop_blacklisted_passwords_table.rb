class DropBlacklistedPasswordsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :blacklisted_passwords
  end
end
