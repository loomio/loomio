# frozen_string_literal: true

class Views::DeliveryMailer::Common::Body < Views::ApplicationMailer::Component

  def initialize(itemable:, recipient:)
    @itemable = itemable
    @recipient = recipient
  end

  def view_template
    div(class: "thread-mailer__body") do
      p { raw TranslationService.formatted_text(@itemable, :body, @recipient) }
      render Views::DeliveryMailer::Common::Attachments.new(resource: @itemable)
    end
  end
end
