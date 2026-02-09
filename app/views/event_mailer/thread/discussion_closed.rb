# frozen_string_literal: true

class Views::EventMailer::Thread::DiscussionClosed < Views::ApplicationMailer::Component

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::EventMailer::Common::Avatar.new(user: @item.user)
        end
        td(class: "content") do
          i { plain t(:"discussion_mailer.discussion_closed.inline", actor: @item.user.name) }
        end
      end
    end
  end
end
