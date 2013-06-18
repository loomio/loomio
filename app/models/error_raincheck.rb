class ErrorRaincheck < ActiveRecord::Base
  attr_accessible :controller, :action, :email
  validates :email, email: true
end
