# frozen_string_literal: true

class Views::EventMailer::Thread::DiscussionEdited < Views::BaseMailer::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::EventMailer::Common::Avatar.new(user: @item.actor)
        end
        td(class: "content") do
          i { plain t(:"discussion_mailer.discussion_edited.inline", actor: @item.actor.name) }
          p { raw MarkdownService.render_plain_text(@item.recipient_message) }
        end
      end
    end
  end
end
