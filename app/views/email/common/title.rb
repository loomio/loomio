# frozen_string_literal: true

class Views::Email::Common::Title < Views::Email::Base

  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    h1(class: "text-h4 event-mailer__title") do
      a(href: tracked_url(@eventable)) { plain plain_text(@eventable, :title) }
    end
  end
end
