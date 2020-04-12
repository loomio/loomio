class Webhook < ApplicationRecord
  belongs_to :group
  validates_presence_of :name, :url

  def publish!(event)
    return unless AppConfig.webhook_event_kinds.include?(event.kind)
    I18n.with_locale(event.group.locale) { client.post_content!(event) }
  end

  private

  def client
    @client ||= Clients::Webhook.new(token: self.url)
  end
end
