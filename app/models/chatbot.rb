class Chatbot < ApplicationRecord
  belongs_to :group
  belongs_to :author, class_name: 'User'

  validates_presence_of :server
  validates_presence_of :name
  validates_inclusion_of :kind, in: ['matrix', 'webhook']
  validates_inclusion_of :webhook_kind, in: ['slack', 'microsoft', 'discord', 'markdown', 'webex', nil]
  validate :server_is_public_url, if: -> { server.present? }

  def config
    {
      # id: self.id,
      server: self.server,
      access_token: self.access_token,
      channel: self.channel
    }
  end

  private

  def server_is_public_url
    errors.add(:server, :invalid) unless LinkPreviewService.safe_to_fetch?(server)
  end
end
