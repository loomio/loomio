class Template < ApplicationRecord
  belongs_to :group
  belongs_to :author, class_name: 'User'
  belongs_to :record, polymorphic: true
  validates :name, presence: true
end
