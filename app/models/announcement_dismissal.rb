class AnnouncementDismissal < ActiveRecord::Base

  belongs_to :announcement
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :announcement_id
end
