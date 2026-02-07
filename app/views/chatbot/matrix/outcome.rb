# frozen_string_literal: true

class Views::Chatbot::Matrix::Outcome < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    return unless @poll.current_outcome

    h5 { t(:"poll_common.outcome") }

    if (option = @poll.current_outcome.poll_option)
      if @poll.poll_option_name_format == 'iso8601'
        p { "Event: #{@poll.current_outcome.event_summary}" }
        p { "Date: #{format_iso8601_for_humans(option.name, @recipient.time_zone, @recipient.date_time_pref)}" }
        p { "Location: #{@poll.current_outcome.event_location}" }
      end
    end

    p { raw TranslationService.formatted_text(@poll.current_outcome, :statement, @recipient) }
    h5 { t(:"poll_types.#{@poll.poll_type}") }
  end
end
