# frozen_string_literal: true

module Views::Chatbot::Slack::Concerns
  private

  def render_slack_results(poll)
    if poll.show_results?
      sd "**#{t(poll.closed_at ? :'poll_common.results' : :'poll_common.current_results')}**"
      md "\n"
      md "\n"

      if poll.poll_type == "meeting"
        render_meeting_table(poll)
      elsif poll.poll_type == "stv"
        render_stv_table(poll)
      else
        render_simple_table(poll)
      end

      md "\n"
    else
      sd "**#{t('poll_common_action_panel.results_hidden_until_closed')}**"
      md "\n"
    end

    slack_convert { render_undecided(poll) }
    md "\n"
  end
end
