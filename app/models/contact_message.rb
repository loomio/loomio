class ContactMessage
  include ActiveModel::Model
  include ActiveModel::Validations

  alias :read_attribute_for_serialization :send
  attr_accessor :name, :email, :user_id, :subject, :message

  validates :email, presence: true, email: true
  validates :message, presence: true, length: { maximum: Rails.application.secrets.max_message_length }
  validates :subject, presence: true, length: { maximum: Rails.application.secrets.max_message_length }

  def save
    valid? && request = client.post_message(self)
  end

  private

  def client
    @client ||= Clients::OsTicket.new
  end
end
