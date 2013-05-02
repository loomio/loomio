class AnnouncementDismissal < ActiveRecord::Base
  attr_accessible :user_id, :announcement_id

  belongs_to :announcement
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :announcement_id
end
