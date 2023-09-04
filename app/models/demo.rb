class Demo < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :group
  validates :name, presence: true
  
  def self.ransackable_attributes(auth_object = nil)
    ["author_id", "created_at", "demo_handle", "description", "group_id", "id", "name", "priority", "recorded_at", "updated_at"]
  end
end
