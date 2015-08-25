class Events::DiscussionDescriptionEdited < Event
  def self.publish!(discussion, editor)
    create!(kind: "discussion_description_edited",
            eventable: discussion,
            user: editor)
  end

  def discussion_key
    eventable.key
  end

  def discussion
    eventable
  end
end
