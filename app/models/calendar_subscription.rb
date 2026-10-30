class CalendarSubscription < ApplicationRecord
  belongs_to :membership
  has_secure_token

  delegate :user, :group, to: :membership

  def available?
    Membership.active.exists?(id: membership_id) && user.active? && group.enabled?
  end
end
