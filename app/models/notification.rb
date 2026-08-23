class Notification < ApplicationRecord
  include PrettyUrlHelper

  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true
  has_many :notification_deliveries, dependent: :destroy

  validates :kind, :subject, :deduplication_key, presence: true

  def notification_url
    return polymorphic_path(subject.group) if kind == "invitation_accepted"

    polymorphic_path(subject)
  end

  def viewed_for?(recipient_id)
    notification_deliveries.any? do |delivery|
      delivery.channel == "in_app" &&
        delivery.recipient_type == "User" &&
        delivery.recipient_id == recipient_id &&
        delivery.viewed?
    end
  end

  def translation_values_for(recipient_id)
    delivery = notification_deliveries.find do |candidate|
      candidate.recipient_type == "User" &&
        candidate.recipient_id == recipient_id &&
        candidate.channel == "in_app"
    end
    delivery&.translation_values.presence || translation_values
  end

  scope :user_mentions, lambda {
    where(kind: %w[user_mentioned comment_replied_to])
  }
  scope :pending_delivery_resolution, lambda {
    where(deliveries_generated_at: nil)
  }
end
