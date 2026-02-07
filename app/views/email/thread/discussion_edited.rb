# frozen_string_literal: true

class Views::Email::Thread::DiscussionEdited < Views::Email::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::Email::Common::Avatar.new(user: @item.actor)
        end
        td(class: "content") do
          i { plain t(:"discussion_mailer.discussion_edited.inline", actor: @item.actor.name) }
          p { raw force_plain_text(@item.recipient_message) }
        end
      end
    end
  end
end
