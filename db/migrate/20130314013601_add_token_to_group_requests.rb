class AddTokenToGroupRequests < ActiveRecord::Migration
  class Invitation < ActiveRecord::Base
  end
  class GroupRequest < ActiveRecord::Base
    def self.generate_token
      begin
        token = SecureRandom.urlsafe_base64
      end while GroupRequest.where(:token => token).exists?
      token
    end
  end

  def up
    add_column :group_requests, :token, :string
    GroupRequest.reset_column_information
    GroupRequest.find_each(batch_size: 200) do |group_request|
      invitation = Invitation.find_by_group_request_id(group_request.id)
      if invitation
        group_request.status = 'accepted' if invitation.accepted?
        group_request.token = invitation.token
      else
        group_request.token = GroupRequest.generate_token
      end
      group_request.save!
    end
  end

  def down
    remove_column :group_requests, :token
  end
end
