class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion)

    if discussion.author.email_on_participation?
      DiscussionReader.for(discussion: discussion,
                           user: discussion.author).change_volume! :email
    end

    ThreadMailerQuery.users_to_email_new_discussion(discussion).each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end
  end

  def discussion
    eventable
  end
end
