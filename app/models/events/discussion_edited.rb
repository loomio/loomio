class Events::DiscussionEdited < Event
  include Events::Notify::Mentions

  def self.publish!(discussion, editor)
    return unless version = discussion.versions.last
    super version,
          user: editor,
          discussion: version.item,
          created_at: version.created_at
  end

  def mention_recipients
    eventable.item.new_mentioned_group_members
  end
end
