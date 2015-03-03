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

  def viewed!(last_viewed_at = Time.now)
    return if user.nil?
    update_viewed_attributes(last_viewed_at)
    save
  end

  def update_viewed_attributes(time = Time.now)
    self.read_votes_count = count_read_votes(time)
    self.read_activity_count = count_read_activity(time)
    self.last_read_at = time
  end

  def count_read_votes(time)
    motion.grouped_unique_votes.select{|v| v.created_at <= time }.count
  end

  def count_read_activity(time)
    motion.votes.where('created_at <= ?', time).count
  end
end
