class ContactRequest
  include ActiveModel::Model

  attr_accessor :message, :sender, :recipient_id

  def save
    UserMailer.contact_request(contact_request: self).deliver_now if valid?
  end
  alias :save! :save

  def valid?
    message.present?
  end

  def recipient
    @recipient ||= User.find self.recipient_id
  end

end
