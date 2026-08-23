# frozen_string_literal: true

class Views::NotificationMailer::TopicItems::DiscussionEdited < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::NotificationMailer::Common::Avatar.new(user: @item.actor)
        end
        td(class: "content") do
          i { plain t(:"discussion_mailer.discussion_edited.inline", actor: @item.actor.name) }
        end
      end
    end
  end
end
