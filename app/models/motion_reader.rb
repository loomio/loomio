class MotionReader < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  validates_presence_of :last_read_at, :motion_id, :user_id
  validates_uniqueness_of :user_id, scope: :motion_id

  def self.for(user: nil, motion: nil)
    if user.is_logged_in?
      where(user_id: user.id, motion_id: motion.id).first_or_initialize do |mr|
        mr.user = user
        mr.motion = motion
      end
    else
      new(motion: motion)
    end
  end

  def unread_votes_count
    motion.total_votes_count - read_votes_count
  end

  def unread_activity_count
    motion.activity_count - read_activity_count
  end

  def new_activity_exists?
    unread_activity_count > 0
  end

  def unfollow!
    self.following = false
    save!
  end

  def viewed!
    return if user.nil?
    update_viewed_attributes
    save
  end

  def update_viewed_attributes
    self.read_votes_count = motion.total_votes_count
    self.read_activity_count = motion.activity_count
    self.last_read_at = Time.zone.now
  end
end
