class Events::DiscussionEdited < Event
  def self.publish!(discussion, editor)
    record_edit = RecordEdit.capture!(discussion, editor)
    create!(kind: "discussion_edited",
            eventable: record_edit,
            user: editor,
            discussion_id: discussion.id)
  end

  def group_key
    discussion.group.key
  end
end
