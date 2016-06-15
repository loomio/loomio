class Events::DiscussionTitleEdited < Event
  def self.publish!(discussion, editor)
    create(kind: "discussion_title_edited",
           eventable: discussion,
           user: editor).tap { |e| EventBus.broadcast('discussion_title_edited_event', e) }
  end
end
