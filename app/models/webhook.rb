# This represents both webhook and api endpoint for an integration
class Webhook < ApplicationRecord
  extend HasTokens
  initialized_with_token :token

  belongs_to :group
  belongs_to :actor, class_name: 'User' # user or bot user that performs the actions
  belongs_to :author

  validates_presence_of :name
  validates_inclusion_of :format, in: ['markdown', 'microsoft', 'slack', 'discord'], if: :url

  scope :not_broken, -> { where(is_broken: false) }
  scope :is_webhook, -> { where("url is not null") }
  before_save :update_actor_name

  def publish!(event)
    return if Rails.env.development? && ENV['WEBHOOKS_DISABLED']
    return unless self.event_kinds.include?(event.kind)
    I18n.with_locale(event.group.locale) { client.post_content!(event, format, self) }
  rescue URI::InvalidURIError
    update(is_broken: true)
  end

  private
  def update_actor_name
    (actor || create_actor(bot: true)).update(name: name)
  end

  def client
    @client ||= Clients::Webhook.new(token: self.url)
  end
end
