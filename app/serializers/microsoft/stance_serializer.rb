class Microsoft::StanceSerializer < Microsoft::BaseSerializer
  def section_title
    object.eventable.poll_option.name
  end

  def section_subtitle
    object.eventable.reason
  end

  def text_options
    super.merge(poll: object.eventable.poll.title)
  end
end
