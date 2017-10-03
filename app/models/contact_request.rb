class ContactRequest
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :message, :sender, :recipient_id
  validates :message, :sender, :recipient, presence: true

  def save
    valid? && UserMailer.contact_request(contact_request: self).deliver_now if valid?
  end
  alias :save! :save

  def recipient
    @recipient ||= User.find self.recipient_id
  end

end
