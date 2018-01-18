module HasEvents
  extend ActiveSupport::Concern

  included do
    has_many :events, -> { includes :user, :eventable }, as: :eventable, dependent: :destroy
    has_many :notifications, through: :events
  end
end
