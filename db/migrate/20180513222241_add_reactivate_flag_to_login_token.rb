class AddReactivateFlagToLoginToken < ActiveRecord::Migration[5.1]
  def change
    add_column :login_tokens, :is_reactivation, :boolean, default:false, null:false
  end
end
