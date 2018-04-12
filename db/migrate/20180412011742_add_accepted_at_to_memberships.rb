class AddAcceptedAtToMemberships < ActiveRecord::Migration[5.1]
  def change
    add_column :memberships, :accepted_at, :datetime
    execute "UPDATE memberships SET accepted_at = created_at"
  end
end
