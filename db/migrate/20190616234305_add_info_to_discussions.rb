class AddInfoToDiscussionsAndGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :info, :jsonb, default: {}, null: false
    add_column :groups, :info, :jsonb, default: {}, null: false

    # Discussion.where(id: DiscussionTag.pluck(:discussion_id)).each do |discussion|
    #   discussion.info[:tags] = DiscussionTag.joins(:tag).where(discussion_id: discussion.id).pluck('tags.name')
    #   discusison.save(validate: false)
    # end
    #
    # Group.where(id: Tag.pluck(:group_id)).each do |group|
    #   group.info[:tags] = Tag.where(group: group).pluck(:name)
    #   group.save(validate: false)
    # end
  end
end
