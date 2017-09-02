class Events::CommentEdited < Event
  include Events::Notify::Mentions
  include Events::LiveUpdate

  def self.publish!(comment, actor)
    super comment, user: actor, created_at: comment.versions.last.created_at
  end

  def mention_recipients
    eventable.new_mentioned_group_members
  end
end
