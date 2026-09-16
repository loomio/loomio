class Notification < ApplicationRecord
  include PrettyUrlHelper

  belongs_to :actor, class_name: "User", optional: true
  belongs_to :subject, polymorphic: true
  has_many :notification_deliveries, dependent: :destroy

  validates :kind, :subject, presence: true

  def notification_url
    return polymorphic_path(subject_model.group) if kind == "invitation_accepted"
    return subject.notification_url if subject.is_a?(TopicItem)

    polymorphic_path(subject_model)
  end

  # A topic-originated notification points at the exact timeline occurrence.
  # Operational notifications point directly at their domain record. Consumers
  # that need the Discussion, Comment, Poll or Outcome use this common unwrap.
  def subject_model
    subject.is_a?(TopicItem) ? subject.itemable : subject
  end

  def self.about(record_or_type, record_id = nil)
    subject_type, subject_id = if record_id
      [ record_or_type, record_id ]
    else
      [ record_or_type.class.base_class.name, record_or_type.id ]
    end
    topic_item_ids = TopicItem.where(
      itemable_type: subject_type,
      itemable_id: subject_id
    ).select(:id)
    direct_ids = where(subject_type: subject_type, subject_id: subject_id).select(:id)
    topic_item_notification_ids = where(
      subject_type: "TopicItem",
      subject_id: topic_item_ids
    ).select(:id)

    # Keep the indexed subject lookups as separate UNION branches. PostgreSQL
    # otherwise turns the equivalent OR into a full notifications table scan.
    where(arel_table[:id].in(direct_ids.arel.union(topic_item_notification_ids.arel)))
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
  scope :pending_delivery_routing, lambda {
    where(deliveries_generated_at: nil)
  }
end
