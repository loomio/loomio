# frozen_string_literal: true

class Views::EventMailer::Poll::ResultsPanel < Views::ApplicationMailer::Component

  def initialize(poll:, current_user:)
    @poll = poll
    @current_user = current_user
  end

  def view_template
    return if @poll.scheduled?

    my_stance = @current_user && ::Stance.latest.find_by(poll_id: @poll.id, participant_id: @current_user.id)

    if @poll.has_options && (@poll.decided_voters_count > 0 || @poll.closed_at)
      div(class: "poll-mailer__results-chart poll-mailer-common-results") do
        if @poll.show_results?(voted: my_stance && my_stance.cast_at)
          h3 { plain t(@poll.closed_at ? :'poll_common.results' : :'poll_common.current_results') }
          if @poll.poll_type == "meeting"
            render Views::EventMailer::Poll::Results::Meeting.new(poll: @poll, recipient: @current_user)
          else
            render Views::EventMailer::Poll::Results::Simple.new(poll: @poll, recipient: @current_user)
          end
        else
          h3 { plain t('poll_common_action_panel.results_hidden_until_closed') }
        end
      end
    end

    render Views::EventMailer::Poll::Undecided.new(poll: @poll)
  end
end
