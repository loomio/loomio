class MotionReader < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  validates_presence_of :last_read_at, :motion_id, :user_id
  validates_uniqueness_of :user_id, scope: :motion_id

  def self.for(motion, user)
    if user.nil?
      new(motion_id: motion.id)
    else
      first_or_create(motion_id: motion.id, user_id: user.id)
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
    update_viewed_attributes
    save!
  rescue ActiveRecord::RecordInvalid
    # race condition occured.. find the original motion reader and mark it as viewed
    reader = self.class.where(user_id: user_id, motion_id: motion_id).first
    if reader
      reader.update_viewed_attributes
      save!
    end
  end

  def update_viewed_attributes
    self.read_votes_count = motion.total_votes_count
    self.read_activity_count = motion.activity_count
    self.last_read_at = Time.zone.now
  end
end
