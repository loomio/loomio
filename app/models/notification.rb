class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User"
  belongs_to :event
  belongs_to :subject, polymorphic: true, optional: true

  validates_presence_of :user, :event

  delegate :locale, to: :user

  def kind
    self[:kind] || kind_from_event
  end

  def eventable
    subject || event&.eventable
  end

  scope :user_mentions, -> { joins(:event).where("events.kind": :user_mentioned) }

  private

  def kind_from_event
    return unless event

    if event.kind == "announcement_created"
      event.custom_fields["kind"] || "group_announced"
    elsif event.kind == "user_mentioned" &&
          event.eventable.respond_to?(:parent) &&
          event.eventable.parent.present? &&
          event.eventable.parent.author == user
      "comment_replied_to"
    else
      event.kind
    end
  end
end
