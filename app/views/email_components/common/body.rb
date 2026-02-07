# frozen_string_literal: true

class Views::EmailComponents::Common::Body < Views::Base
  include EmailHelper

  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    div(class: "thread-mailer__body") do
      p { raw formatted_text(@eventable, :body) }
      render Views::EmailComponents::Common::Attachments.new(resource: @eventable)
    end
  end
end
