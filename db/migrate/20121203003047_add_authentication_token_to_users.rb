class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :authentication_token, :string
    User.all.each do |user|
      user.ensure_authentication_token!
    end
  end
end
