# Migration-only representation of the events table. The final application no
# longer defines Event, but anonymous-vote upgrades still run before the table is
# renamed to topic_items.
class LegacyEventRecord < ActiveRecord::Base
  self.table_name = "events"

  belongs_to :eventable, polymorphic: true
  belongs_to :user, optional: true
  has_many :notifications, foreign_key: :event_id, dependent: :delete_all
end

class LegacyNotificationRecord < ActiveRecord::Base
  self.table_name = "notifications"
end
