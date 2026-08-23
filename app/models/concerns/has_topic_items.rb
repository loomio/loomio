module HasTopicItems
  extend ActiveSupport::Concern

  included do
    has_many :topic_items, -> { includes :user, :itemable }, as: :itemable, dependent: :destroy
    has_many :notifications, as: :subject, dependent: :destroy
  end
end
