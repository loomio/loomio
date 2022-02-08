class Chatbot < ApplicationRecord
  belongs_to :group
  belongs_to :author

  validates_inclusion_of :kind, in: ['matrix', 'slack', 'discord']

  def client
    @client ||= begin
      client = Clients::Matrix.new(host: self.server)
      client.login(self.login, self.password)
      client
    end
  end
end
