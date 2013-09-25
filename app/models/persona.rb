class Persona < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :email
end
