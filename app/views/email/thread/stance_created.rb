# frozen_string_literal: true

class Views::Email::Thread::StanceCreated < Views::Email::Base

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
              render Views::Email::Common::Avatar.new(user: @participant)
            end
          end
        end
        td { plain @participant.name }
        td do
          render Views::Email::Poll::StanceChoices.new(
            stance: @stance,
            poll: @stance.poll,
            recipient: @recipient
          )
        end
      end
    end

    p { raw formatted_text(@stance, :reason) }
  end
end
