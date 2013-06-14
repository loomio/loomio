class ErrorRaincheck < ActiveRecord::Base
  attr_accessible :action, :email
  validates :email, email: true
end
