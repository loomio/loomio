class TopicItems::DiscussionDescriptionEdited < TopicItem
  def self.publish!(discussion, editor)
    super discussion, user: editor
  end
end
