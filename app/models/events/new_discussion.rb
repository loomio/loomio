class Events::NewDiscussion < Event
  after_create :notify_users!

  def self.publish!(discussion)
    create!(:kind => "new_discussion", :eventable => discussion,
                      :discussion_id => discussion.id)
  end

  def discussion
    eventable
  end

  private

  def notify_users!
    discussion.group_users_without_discussion_author.each do |user|
      if user.email_notifications_for_group?(discussion.group)
        DiscussionMailer.new_discussion_created(discussion, user).deliver
      end
      notify!(user)
    end
  end

  handle_asynchronously :notify_users!
end
