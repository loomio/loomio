class FixNewDiscussionSequences < ActiveRecord::Migration
  def up
    Event.where('kind = ? AND sequence_id IS NOT NULL', :new_discussion).update_all(sequence_id: nil)
  end
end
