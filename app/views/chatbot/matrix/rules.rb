# frozen_string_literal: true

class Views::Chatbot::Matrix::Rules < Views::Chatbot::Base
  def initialize(poll:)
    @poll = poll
  end

  def view_template
    return unless @poll.quorum_pct || @poll.results.any? { |r| r[:test_operator] }

    h3 { t('poll_common_action_panel.for_this_poll_type_to_be_valid', poll_type: t("poll_types.#{@poll.poll_type}")) }
    ul do
      if @poll.quorum_pct
        li { t('poll_common_percent_voted.pct_of_eligible_voters_must_participate', pct: @poll.quorum_pct) }
      end
      @poll.results.select { |r| r['test_operator'] }.each do |option|
        li { t("poll_option_form.name_#{option['test_operator']}_#{option['test_against']}", percent: option['test_percent'], name: option['name']) }
      end
    end
  end
end
