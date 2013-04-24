class UpdateToVerifiedAndDeferedGroupRequests < ActiveRecord::Migration
  class GroupRequest < ActiveRecord::Base
  end

  def up
    GroupRequest.where(status: 'awaiting_approval').update_all(status: 'verified')
    GroupRequest.where(status: 'ignored').update_all(status: 'defered')
  end

  def down
    GroupRequest.where(status: 'verified').update_all(status: 'awaiting_approval')
    GroupRequest.where(status: 'defered').update_all(status: 'ignored')
  end
end
