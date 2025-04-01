class Task < ApplicationRecord
  include Discard::Model

  belongs_to :record, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :doer, class_name: 'User'

  scope :not_done, -> { where(done: false) }

  has_many :tasks_users
  has_many :users, through: :tasks_users

  has_many :tasks_users_extensions, dependent: :destroy
end
