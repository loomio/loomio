# frozen_string_literal: true

class Views::EventMailer::Poll::Stance < Views::BaseMailer::Base

  def initialize(stance:, recipient:)
    @stance = stance
    @recipient = recipient
  end

  def view_template
    div(class: "poll-mailer__stance") do
      table do
        poll = @stance.poll
        @stance.stance_choices.order('score desc').each do |choice|
          render Views::EventMailer::Poll::PollOption.new(
            poll: poll,
            poll_option: choice.poll_option,
            stance: @stance,
            recipient: @recipient
          )
        end
      end

      if @stance.real_participant == @recipient && @stance.poll.active?
        a(href: tracked_url(@stance.poll, recipient: @recipient, args: { change_vote: @stance.poll.id })) do
          plain t(:"poll_common.change_vote")
        end
      end

      p { raw TranslationService.formatted_text(@stance, :reason, @recipient) }
    end
  end
end
