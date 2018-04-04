module HasEvents
  extend ActiveSupport::Concern

  included do
    has_many :events, -> { includes :user, :eventable }, as: :eventable, dependent: :destroy
    has_many :notifications, through: :events
  end

  def users_announced_to
    user_ids = self.events.where(kind: :announcement_created).pluck(:custom_fields).map { |f| f['recipient_id'] }
    User.distinct.where(id: user_ids)
  end
end
