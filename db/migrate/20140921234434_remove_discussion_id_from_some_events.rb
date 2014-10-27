class RemoveDiscussionIdFromSomeEvents < ActiveRecord::Migration
  def change
    Event.where(kind: ['motion_closing_soon', 'new_discussion']).update_all('discussion_id = null')
  end
end
