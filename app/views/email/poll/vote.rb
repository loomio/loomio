# frozen_string_literal: true

class Views::Email::Poll::Vote < Views::Email::Base

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
        render Views::Email::Poll::Stance.new(stance: stance, recipient: @recipient)
      elsif @poll.active?
        h2(class: "text-subtitle-2") { plain t(:"poll_common.please_vote") }

        if @poll.poll_type == 'meeting'
          p do
            plain t(:"common.time_zone")
            plain " "
            plain ActiveSupport::TimeZone[@recipient.time_zone].to_s
          end
        end

        @poll.poll_options.each do |option|
          render Views::Email::Poll::PollOption.new(
            poll: @poll,
            poll_option: option,
            stance: stance,
            recipient: @recipient
          )
        end

        unless @poll.is_single_choice?
          render Views::Email::Common::Button.new(
            url: tracked_url(@poll, recipient: @recipient),
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
