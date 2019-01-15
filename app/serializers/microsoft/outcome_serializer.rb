class Microsoft::OutcomeSerializer < Microsoft::PollSerializer
  def section_subtitle
    object.eventable.statement
  end

  def additional_section_facts
    []
  end
end
