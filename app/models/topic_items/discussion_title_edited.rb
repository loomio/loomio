class TopicItems::DiscussionTitleEdited < TopicItem
  def self.publish!(discussion, editor)
    super discussion, user: editor, created_at: Time.now
  end
end
