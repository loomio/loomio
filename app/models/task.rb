class Task < ApplicationRecord
  include Discard::Model

  belongs_to :record, polymorphic: true
  belongs_to :author, class_name: 'User'
  belongs_to :doer, class_name: 'User'

  scope :not_done, -> { where(done_at: nil) }

  def done?
    done_at.present?
  end

  has_many :tasks_users, dependent: :destroy
  has_many :users, through: :tasks_users
end
