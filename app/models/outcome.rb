class Outcome < ActiveRecord::Base
  belongs_to :poll, required: true
  has_one :discussion, through: :poll
  belongs_to :author, class_name: 'User', required: true

  has_paper_trail only: [:statement]

  attr_accessor :make_announcement

  validates :statement, presence: true
end
