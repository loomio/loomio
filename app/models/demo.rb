class Demo < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :group
  validates :name, presence: true
end
