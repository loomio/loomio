class PopulateShareableLinks < ActiveRecord::Migration[5.1]
  def change
    Group.connection.execute("
      UPDATE groups SET token = invitations.token
      FROM   invitations
      WHERE  invitations.single_use = false
      AND    invitations.group_id = groups.id
    ")
  end
end
