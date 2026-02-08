# frozen_string_literal: true

class Views::EventMailer::Common::Tags < Views::BaseMailer::Base
  def initialize(eventable:)
    @eventable = eventable
  end

  def view_template
    @eventable.tag_models.each do |tag|
      span(class: "mailer-tag", style: "color: #{tag.color}; border-color: #{tag.color}") { plain tag.name }
    end
  end
end
