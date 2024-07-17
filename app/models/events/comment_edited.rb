class Events::CommentEdited < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::Audiences

  def self.publish!(comment, actor)
    super(comment, user: actor)
  end
end
