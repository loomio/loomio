# frozen_string_literal: true

class Views::NotificationMailer::TopicItems::DiscussionClosed < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "email-activity-avatar") do
          render Views::NotificationMailer::Common::Avatar.new(user: @item.user)
        end
        td(class: "email-activity-content") do
          i { plain t(:"discussion_mailer.discussion_closed.inline", actor: @item.user.name) }
        end
      end
    end
  end
end
