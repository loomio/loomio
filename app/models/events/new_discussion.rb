class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion)

    dr = DiscussionReader.for(discussion: discussion, user: discussion.author)
    dr.set_volume_as_required!
    dr.participate!

    UsersToEmailQuery.new_discussion(discussion).find_each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end

    event
  end

  def group_key
    eventable.group.key
  end

  def discussion
    eventable
  end
end
