# frozen_string_literal: true

class Views::NotificationMailer::Common::Tags < Views::ApplicationMailer::Component
  def initialize(itemable:)
    @itemable = itemable
  end

  def view_template
    @itemable.topic.tag_models.each do |tag|
      span(class: "mailer-tag", style: "color: #{tag.color}; border-color: #{tag.color}") { plain tag.name }
    end
  end
end
