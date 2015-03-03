class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion)

    DiscussionReader.for(discussion: discussion,
                         user: discussion.author).
                     set_volume_as_required!

    UsersToEmailQuery.new_discussion(discussion).each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end
  end

  def discussion
    eventable
  end
end
