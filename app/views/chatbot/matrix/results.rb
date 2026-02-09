# frozen_string_literal: true

class Views::Chatbot::Matrix::Results < Views::Chatbot::Base
  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    if @poll.decided_voters_count > 0 || @poll.closed_at
      if @poll.show_results?
        h5 { t(@poll.closed_at ? :'poll_common.results' : :'poll_common.current_results') }
        if @poll.poll_type == "meeting"
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

    render Views::Chatbot::Matrix::Undecided.new(poll: @poll)
  end
end
