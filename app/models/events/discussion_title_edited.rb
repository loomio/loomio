class Events::DiscussionTitleEdited < Event
  def self.publish!(discussion, editor)
    create!(kind: "discussion_title_edited",
            eventable: discussion,
            user: editor,
            discussion_id: discussion.id)
  end

  def group_key
    discussion.group.key
  end

  def discussion
    eventable
  end
end
