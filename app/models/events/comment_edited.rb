class Events::CommentEdited < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions

  def self.publish!(comment, actor)
    super(comment, user: actor)
  end
end
