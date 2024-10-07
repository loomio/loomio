class AddEmailSha256ToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_sha256, :string
  end
end
