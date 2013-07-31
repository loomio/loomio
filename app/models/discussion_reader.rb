class DiscussionReader < ActiveRecord::Base
  attr_accessible :user_id, :discussion_id, :last_read_at, :following, :read_comments_count

  belongs_to :user
  belongs_to :discussion

  validates_presence_of :discussion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :discussion_id

  after_initialize :set_defaults

  def self.load_from_joined_discussion(discussion)
    dv = new
    dv.id = discussion[:viewer_id].to_i
    dv.discussion_id = discussion.id.to_i
    dv.user_id = discussion[:viewer_user_id].to_i
    dv.read_comments_count = discussion[:read_comments_count].to_i
    dv.last_read_at = discussion[:last_read_at]
    dv.following = discussion[:viewer_following]
    dv.discussion = discussion
    dv.instance_variable_set :@attributes_cache, dv.attributes
    dv.instance_variable_set :@new_record, false
    dv
  end

  def unread_comments_count
    #we count the discussion itself as a comment.. but it is comment 0
    if read_comments_count.nil?
      discussion.comments_count + 1
    else
      discussion.comments_count.to_i - read_comments_count
    end
  end

  def unread_content_exists?
    unread_comments_count > 0
  end

  def self.for(discussion, user)
    self.first_or_create(discussion_id: discussion.id, user_id: user.id)
  end

  def unfollow!
    self.following = false
    save!
  end

  def viewed!
    self.read_comments_count = discussion.comments_count
    self.last_read_at = Time.now
    save!
    discussion.viewed!
  end

  private
  def set_defaults
    #self.read_comments_count ||= 0
  end
end
