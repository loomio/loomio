# frozen_string_literal: true

class Views::EventMailer::Thread::NewComment < Views::BaseMailer::Base

  def initialize(item:, recipient:)
    @item = item
    @recipient = recipient
    @comment = item.eventable
  end

  def view_template
    table do
      tr do
        td(class: "icon") do
          render Views::EventMailer::Common::Avatar.new(user: @comment.author)
        end
        td(class: "content") do
          if @comment.discarded?
            plain t(:"thread_item.removed")
          else
            b { plain @comment.author.name_or_username }
            p { raw TranslationService.formatted_text(@comment, :body, @recipient) }
            if @comment.documents.any?
              render Views::EventMailer::Common::Attachments.new(resource: @comment)
            end
          end
        end
      end
    end
  end
end
