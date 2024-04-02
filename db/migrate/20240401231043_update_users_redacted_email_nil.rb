class UpdateUsersRedactedEmailNil < ActiveRecord::Migration[7.0]
  def change
    User.deactivated.where('email ilike ?', 'deactivated-user-%').update_all(email: nil)
  end
end
