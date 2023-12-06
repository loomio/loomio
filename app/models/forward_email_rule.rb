class ForwardEmailRule < ApplicationRecord
   def self.ransackable_attributes(auth_object = nil)
    ["email", "handle", "id"]
  end
end
