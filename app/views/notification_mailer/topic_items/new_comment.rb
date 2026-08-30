# frozen_string_literal: true

class Views::NotificationMailer::TopicItems::NewComment < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @comment = item.itemable
  end

  def view_template
    table do
      tr do
        td(class: "email-activity-avatar") do
          render Views::NotificationMailer::Common::Avatar.new(user: @comment.author)
        end
        td(class: "email-activity-content") do
          if @comment.discarded?
            plain t(:"thread_item.removed")
          else
            div(class: "email-meta") { plain @comment.author.name_or_username }
            div(class: "email-user-content") { raw TranslationService.formatted_text(@comment, :body, @recipient) }
            render Views::NotificationMailer::Common::Attachments.new(resource: @comment)
          end
        end
      end
    end
  end
end
