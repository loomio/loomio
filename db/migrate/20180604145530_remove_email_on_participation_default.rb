class RemoveEmailOnParticipationDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:users, :email_on_participation, from: true, to: nil)
  end
end
