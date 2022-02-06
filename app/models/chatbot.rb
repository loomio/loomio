class Chatbot < ApplicationRecord
  belongs_to :group
  belongs_to :author

  validates_inclusion_of :kind, in: ['matrix', 'slack', 'discord']

  def client
    @client ||= Clients::Webhook.new(token: self.url)
  end
end
