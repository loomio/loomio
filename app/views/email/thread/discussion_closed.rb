# frozen_string_literal: true

class Views::Email::Thread::DiscussionClosed < Views::Email::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::Email::Common::Avatar.new(user: @item.user)
        end
        td(class: "content") do
          i { plain t(:"discussion_mailer.discussion_closed.inline", actor: @item.user.name) }
        end
      end
    end
  end
end
