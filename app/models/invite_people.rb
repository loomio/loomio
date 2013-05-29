class InvitePeople
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :recipients, :message_body

  validates_presence_of :recipients


  def parsed_recipients
    recipients.split(',').map(&:strip)
  end

  def initialize(attributes = {})
    return if attributes.nil?
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def recipient_list
    recipients.split(',')
  end
end
