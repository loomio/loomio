# frozen_string_literal: true

class Views::NotificationMailer::TopicItems::PollEdited < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @poll = item.itemable
    @notification = item.notifications.detect { |notification| notification.kind == item.kind }
  end

  def view_template
    table do
      tr do
        td(class: "email-activity-avatar") do
          render Views::NotificationMailer::Common::Avatar.new(user: @item.actor)
        end
        td(class: "email-activity-content") do
          i do
            plain t(:"poll_mailer.subject.poll_edited",
              actor: @item.actor.name,
              poll_type: t("poll_types.#{@poll.poll_type}"),
              title: @poll.title)
          end
          if @notification&.recipient_message.present?
            p { raw MarkdownService.render_plain_text(@notification.recipient_message) }
          end
        end
      end
    end
  end
end
