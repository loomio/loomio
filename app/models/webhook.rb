class Webhook < ApplicationRecord
  belongs_to :group
  validates_presence_of :name, :url, :format
  validates_inclusion_of :format, in: ['markdown', 'microsoft', 'slack']

  def publish!(event)
    return unless self.event_kinds.include?(event.kind)
    I18n.with_locale(event.group.locale) { client.post_content!(event, format, self) }
  end

  private

  def client
    @client ||= Clients::Webhook.new(token: self.url)
  end
end
