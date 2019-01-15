class Microsoft::OutcomeSerializer < Microsoft::PollSerializer
  def section_subtitle
    object.eventable.statement
  end
end
