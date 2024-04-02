class UpdateLoomioHelperBotEmail < ActiveRecord::Migration[7.0]
  def change
    User.where(email: 'contact@loomio.org').update_all(email: 'notifications@loomio.com')
  end
end
