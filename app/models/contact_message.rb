class ContactMessage
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :email, :message

  validates_presence_of :name, :message
  validates :email, presence: true, email: true
  validates :message, presence: true, length: { maximum: Rails.application.secrets.max_message_length }

  def save
    byebug
    client.messages.create(
      from: {
        type: :user,
        id: User.find_by(email: self.email)&.id,
        name: self.name,
        email: self.email
      },
      body: self.message
    ) if valid?
  end

  private

  def client
    @client ||= Intercom::Client.new(token: ENV["INTERCOM_ACCESS_TOKEN"])
  end
end
