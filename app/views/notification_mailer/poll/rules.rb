# frozen_string_literal: true

class Views::NotificationMailer::Poll::Rules < Views::ApplicationMailer::Component

  def initialize(poll:)
    @poll = poll
  end

  def view_template
    return unless @poll.quorum_pct || @poll.results.any? { |r| r[:test_operator] }

    h3 { plain t('poll_common_action_panel.for_this_poll_type_to_be_valid', poll_type: t("poll_types.#{@poll.poll_type}")) }
    ul do
      if @poll.quorum_pct
        met = @poll.quorum_reached?
        li { plain "#{met ? '✓' : '✗'} #{t(@poll.quorum_requirement_key, pct: @poll.quorum_pct)}" }
      end
      @poll.results.select { |r| r['test_operator'] }.each do |option|
        met = option['test_result']
        li { plain "#{met ? '✓' : '✗'} #{t(option['test_requirement_key'], percent: option['test_percent'], name: option['name'])}" }
      end
    end
  end
end
