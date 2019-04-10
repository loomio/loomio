class Microsoft::CommentSerializer < Microsoft::BaseSerializer
  def section_title
    object.discussion.title
  end

  def section_subtitle
    object.eventable.body
  end
end
