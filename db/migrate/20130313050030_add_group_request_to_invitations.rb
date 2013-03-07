class AddGroupRequestToInvitations < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base
    belongs_to :group_request
  end
  class GroupRequest < ActiveRecord::Base
  end

  def up
    add_column :invitations, :group_request_id, :integer
    add_index :invitations, :group_request_id
    Invitation.reset_column_information
    Invitation.find_each(batch_size: 200) do |invitation|
      group_request = GroupRequest.where(group_id: invitation.group_id).first
      invitation.group_request = group_request
      invitation.save
    end
  end

  def down
    remove_column :invitations, :group_request_id
  end
end
