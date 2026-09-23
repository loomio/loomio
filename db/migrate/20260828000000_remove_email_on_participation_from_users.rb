class RemoveEmailOnParticipationFromUsers < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :email_on_participation
  end

  def down
    add_column :users, :email_on_participation, :boolean, default: false, null: false
  end
end
