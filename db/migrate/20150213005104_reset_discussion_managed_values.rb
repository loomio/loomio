class ResetDiscussionManagedValues < ActiveRecord::Migration
  def change
    raise "migration does not work" if Event.where('discussion_id is not null').where('sequence_id is null').any?

    puts "Resetting items_count, salient_items_count, comments_count for all discussions"
    Discussion.find_each do |discussion|
      Discussion.where(id: discussion.id).update_all(items_count: discussion.items.count,
                                                     salient_items_count: discussion.salient_items.count,
                                                     comments_count: discussion.comments.count)
    end

  end
end
