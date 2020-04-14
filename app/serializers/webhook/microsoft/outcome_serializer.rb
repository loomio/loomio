class Webhook::Microsoft::OutcomeSerializer < Webhook::Microsoft::PollSerializer
  def section_subtitle
    object.eventable.statement
  end
end
