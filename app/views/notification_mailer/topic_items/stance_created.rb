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
        td(class: "email-activity-avatar") do
          a(href: user_url(@participant)) do
            render Views::NotificationMailer::Common::Avatar.new(user: @participant)
          end
        end
        td(class: "email-meta") { plain @participant.name }
        td do
          render Views::NotificationMailer::Poll::StanceChoices.new(
            stance: @stance,
            poll: @stance.poll,
            recipient: @recipient
          )
        end
      end
    end

    div(class: "email-user-content") { raw TranslationService.formatted_text(@stance, :reason, @recipient) }
  end
end
