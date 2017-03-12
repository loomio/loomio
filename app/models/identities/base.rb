class Identities::Base < ActiveRecord::Base
  extend HasCustomFields
  self.table_name = :identities
  validates :identity_type, presence: true
  validates :access_token, presence: true

  belongs_to :user, required: true

  discriminate Identities, on: :identity_type

  def self.set_identity_type(type)
    after_initialize { self.identity_type = type }
  end

  def as_type
    yield "Identities::#{class_name}".constantize.new(self.as_json)
  end

  private

  def client
    @client ||= "Clients::#{class_name}".constantize.new(token: self.access_token)
  end

  def class_name
    identity_type.to_s.classify
  end
end
