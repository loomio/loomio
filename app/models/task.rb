class Task < ApplicationRecord
  include Discard::Model
  
  belongs_to :record, polymorphic: true
  belongs_to :author, class_name: 'User'

  has_many :tasks_user
  has_many :users, through: :tasks_user
end
