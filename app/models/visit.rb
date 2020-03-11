class Visit < ApplicationRecord
  has_many :ahoy_events, class_name: "Ahoy::Event"
  belongs_to :user

  before_create :set_gclid

  def set_gclid
    self.gclid = landing_params["gclid"]
  end
end
