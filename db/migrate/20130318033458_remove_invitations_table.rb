class RemoveInvitationsTable < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base
  end
  class GroupRequest < ActiveRecord::Base
    belongs_to :group

    def accepted?
      status == 'accepted'
    end
  end

  def up
    drop_table :invitations
  end

  def down
    create_table :invitations do |t|
      t.string :recipient_email
      t.integer :inviter_id
      t.integer :group_id
      t.string :token
      t.boolean :accepted, default: false
      t.integer :group_request_id
    end
    GroupRequest.includes(:group).where("group_id IS NOT NULL").find_each(batch_size: 200) do |group_request|
      invitation = Invitation.new
      invitation.recipient_email = group_request.admin_email
      invitation.inviter_id = group_request.group.creator_id
      invitation.group_id = group_request.group_id
      invitation.token = group_request.token
      invitation.accepted = group_request.accepted? ? true : false
      invitation.group_request_id = group_request.id
      invitation.save!
    end
  end
end
