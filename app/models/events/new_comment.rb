class Events::NewComment < Event
  after_create :notify_users!

  def self.publish!(comment)
    create!(:kind => "new_comment", :eventable => comment,
                    :discussion_id => comment.discussion.id)
  end

  def comment
    eventable
  end

  private

  def notify_users!
    comment.mentioned_group_members.each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end
    comment.non_mentioned_discussion_participants.each do |non_mentioned_user|
      notify!(non_mentioned_user)
    end
  end

  handle_asynchronously :notify_users!
end
