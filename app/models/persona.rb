class Persona < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :email

  def for_email(email)
    self.class.where(email: email).first_or_create
  end
end
