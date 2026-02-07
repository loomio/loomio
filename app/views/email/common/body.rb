# frozen_string_literal: true

class Views::Email::Common::Body < Views::Email::Base

  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    div(class: "thread-mailer__body") do
      p { raw formatted_text(@eventable, :body) }
      render Views::Email::Common::Attachments.new(resource: @eventable)
    end
  end
end
