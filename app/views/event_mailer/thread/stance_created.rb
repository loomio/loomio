# frozen_string_literal: true

class Views::EventMailer::Thread::StanceCreated < Views::BaseMailer::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @stance = item.eventable
    @participant = @stance.participant
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          a(href: user_url(@participant)) do
            div(class: "medium-user-avatar #{@participant.avatar_kind}-user-avatar avatar-canvas") do
              render Views::EventMailer::Common::Avatar.new(user: @participant)
            end
          end
        end
        td { plain @participant.name }
        td do
          render Views::EventMailer::Poll::StanceChoices.new(
            stance: @stance,
            poll: @stance.poll,
            recipient: @recipient
          )
        end
      end
    end

    p { raw TranslationService.formatted_text(@stance, :reason, @recipient) }
  end
end
