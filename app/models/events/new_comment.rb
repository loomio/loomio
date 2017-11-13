class Events::NewComment < Event
  include Events::Notify::Mentions
  include Events::Notify::Users
  include Events::LiveUpdate

  def self.publish!(comment)
    super(comment, user: comment.author, discussion: comment.discussion)
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .without(eventable.author)
                               .without(eventable.new_mentioned_group_members)
                               .without(eventable.parent_author)
  end

  def mention_recipients
    eventable.new_mentioned_group_members
  end

  def mailer
    ThreadMailer
  end
end
