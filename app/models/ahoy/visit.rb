class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true
  
  def track_visit(options)
    super do |visit|
      visit.gclid = visit_properties.landing_params["gclid"]
    end
  end
end
