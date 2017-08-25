class ChangeEmailOnParticipationToTrue < ActiveRecord::Migration
  def change
    change_column :users, :email_on_participation, :boolean, default: true, null: false
  end
end
