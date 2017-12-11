class Events::NewComment < Event
  include Events::Notify::Users
  include Events::LiveUpdate

  def self.publish!(comment)
    create(kind: 'new_comment',
           eventable: comment,
           parent: lookup_parent_event(comment),
           user:   comment.author,
           discussion: comment.discussion,
           created_at: comment.created_at).tap { |e| EventBus.broadcast('new_comment_event', e) }
  rescue ActiveRecord::RecordNotUnique
    retry
  end


  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .without(eventable.author)
                               .without(eventable.mentioned_group_members)
                               .without(eventable.parent_author)
  end
end
