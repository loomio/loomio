# frozen_string_literal: true

class Views::NotificationMailer::TopicItems::StanceCreated < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @stance = item.itemable
    @participant = @stance.participant
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          a(href: user_url(@participant)) do
            div(class: "medium-user-avatar #{@participant.avatar_kind}-user-avatar avatar-canvas") do
              render Views::NotificationMailer::Common::Avatar.new(user: @participant)
            end
          end
        end
        td { plain @participant.name }
        td do
          render Views::NotificationMailer::Poll::StanceChoices.new(
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
