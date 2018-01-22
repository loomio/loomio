class Events::NewComment < Event
  include Events::Notify::Users
  include Events::LiveUpdate

  def self.publish!(comment)
    create(kind: 'new_comment',
           eventable: comment,
           parent: comment.parent_event,
           user:   comment.author,
           discussion: comment.discussion,
           created_at: comment.created_at).tap { |e| EventBus.broadcast('new_comment_event', e) }
  rescue ActiveRecord::RecordNotUnique
    retry
  end


  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_group_members)
                               .where.not(id: eventable.parent_author)
  end
end
