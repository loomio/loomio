# frozen_string_literal: true

class Views::Chatbot::Matrix::Results < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    return if @poll.scheduled?

    if @poll.vote_count_cast > 0 || @poll.closed_at
      if @poll.results_visible?
        h5 { t(@poll.closed_at ? :'poll_common.results' : :'poll_common.current_results') }
        if @poll.poll_type == "availability"
          render Views::Chatbot::Matrix::Meeting.new(poll: @poll, recipient: @recipient)
        elsif @poll.poll_type == "stv"
          render Views::Chatbot::Matrix::Stv.new(poll: @poll, recipient: @recipient)
        else
          render Views::Chatbot::Matrix::Simple.new(poll: @poll, recipient: @recipient)
        end
      else
        h5 { t('poll_common_action_panel.results_hidden_until_closed') }
      end
    end

    render Views::Chatbot::Matrix::Uncast.new(poll: @poll)
  end
end
