class Chatbot < ApplicationRecord
  belongs_to :group
  belongs_to :author

  validates_inclusion_of :kind, in: ['matrix', 'slack', 'discord', 'mattermost', 'teams']

  def config
    {
      id: self.id,
      server: self.server,
      access_token: self.access_token,
      channel: self.channel
    }
  end
end
