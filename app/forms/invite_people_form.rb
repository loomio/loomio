class InvitePeopleForm
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :recipients, :message_body, :parent_members_to_add, :subject

  validates_presence_of :recipients

  def initialize(attributes = {})
    return if attributes.nil?
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

  def emails_to_invite
    parsed_emails - members_to_add.map(&:email)
  end

  def members_to_add
    users_recognised_by_email + users_recognised_by_id
  end

  private

  def parsed_emails
    if recipients.present?
      recipients.split(',').map(&:strip)
    else
      []
    end
  end

  def users_recognised_by_id
    User.where(id: parent_members_to_add)
  end

  def users_recognised_by_email
    User.where(email: parsed_emails)
  end
end
