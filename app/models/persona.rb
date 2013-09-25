class Persona < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :email

  def self.for_email(email)
    where(email: email).first_or_create
  end
end
