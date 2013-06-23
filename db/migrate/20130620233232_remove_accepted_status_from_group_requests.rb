class RemoveAcceptedStatusFromGroupRequests < ActiveRecord::Migration
  class GroupRequest < ActiveRecord::Base
  end

  def up
    GroupRequest.where(status: :accepted).update_all(status: :approved)
  end

  def down
  end
end
