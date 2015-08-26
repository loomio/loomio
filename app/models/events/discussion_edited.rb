class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    version = discussion.versions.last
    create!(kind: "discussion_edited",
            eventable: version,
            user: editor,
            discussion_id: discussion.id)
  end

  def group_key
    discussion.group.key
  end
end
