class Webhook < ApplicationRecord
  belongs_to :group
  validates_presence_of :name, :url, :format
  validates_inclusion_of :format, in: ['markdown', 'microsoft', 'slack']

  scope :include_subgroups, -> { where(include_subgroups: true) }
  scope :not_broken, -> { where(is_broken: false) }

  def publish!(event)
    return unless self.event_kinds.include?(event.kind)
    I18n.with_locale(event.group.locale) { client.post_content!(event, format, self) }
  rescue URI::InvalidURIError
    update(is_broken: true)
  end

  private

  def client
    @client ||= Clients::Webhook.new(token: self.url)
  end
end
