class Microsoft::StanceSerializer < Microsoft::BaseSerializer
  def section_title
    object.eventable.poll.title
  end

  def section_subtitle
    object.eventable.reason
  end
end
