# frozen_string_literal: true

class Views::EventMailer::Thread::PollEdited < Views::BaseMailer::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @poll = item.eventable
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::EventMailer::Common::Avatar.new(user: @item.actor)
        end
        td(class: "content") do
          i do
            plain t(:"poll_mailer.subject.poll_edited",
              actor: @item.actor.name,
              poll_type: t("poll_types.#{@poll.poll_type}"),
              title: @poll.title)
          end
          p { raw MarkdownService.render_plain_text(@item.recipient_message) }
        end
      end
    end
  end
end
