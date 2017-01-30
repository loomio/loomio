class Outcome < ActiveRecord::Base
  belongs_to :poll, required: true
  belongs_to :author, class_name: 'User', required: true

  attr_accessor :make_announcement

  validates :statement, presence: true
end
