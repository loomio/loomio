# frozen_string_literal: true

class Views::EmailComponents::Poll::Vote < Views::Base
  include Phlex::Rails::Helpers::T
  include EmailHelper
  include FormattedDateHelper

  def initialize(poll:, recipient:)
    @poll = poll
    @recipient = recipient
  end

  def view_template
    stance = recipient_stance(@recipient, @poll)

    div(class: "poll-mailer__vote pb-4") do
      if @poll.anonymous?
        p { plain t(:"poll_common_action_panel.anonymous") }
      end

      if stance.cast_at
        h2(class: "text-subtitle-2") { plain t(:"poll_common.your_response") }
        render Views::EmailComponents::Poll::Stance.new(stance: stance, recipient: @recipient)
      elsif @poll.active?
        h2(class: "text-subtitle-2") { plain t(:"poll_common.please_vote") }

        if @poll.poll_type == 'meeting'
          p do
            plain t(:"common.time_zone")
            plain " "
            plain formatted_time_zone
          end
        end

        @poll.poll_options.each do |option|
          render Views::EmailComponents::Poll::PollOption.new(
            poll: @poll,
            poll_option: option,
            stance: stance,
            recipient: @recipient
          )
        end

        unless @poll.is_single_choice?
          render Views::EmailComponents::Common::Button.new(
            url: tracked_url(@poll),
            text: t(:"poll_common.vote_now")
          )
        end
      end

      if @poll.wip?
        p { plain t(:"poll_common_action_panel.draft_mode", poll_type: t("poll_types.#{@poll.poll_type}")) }
      end
    end
  end
end
