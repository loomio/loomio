# frozen_string_literal: true

class Views::NotificationMailer::Common::Title < Views::ApplicationMailer::Component

  def initialize(itemable:, recipient:, heading_tag: :h1)
    @itemable = itemable
    @recipient = recipient
    @heading_tag = heading_tag
  end

  def view_template
    public_send(@heading_tag) do
      a(class: "notification-title__link notification-title__link--#{@itemable.class.name.underscore}", href: tracked_url(@itemable, recipient: @recipient)) { plain TranslationService.plain_text(@itemable, :title, @recipient) }
    end
  end
end
