# frozen_string_literal: true

class Views::DeliveryMailer::Common::Title < Views::ApplicationMailer::Component

  def initialize(itemable:, recipient:)
    @itemable = itemable
    @recipient = recipient
  end

  def view_template
    h1(class: "text-h4 delivery-mailer__title") do
      a(href: tracked_url(@itemable, recipient: @recipient)) { plain TranslationService.plain_text(@itemable, :title, @recipient) }
    end
  end
end
