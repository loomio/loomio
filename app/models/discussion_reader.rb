class DiscussionReader < ActiveRecord::Base

  belongs_to :user
  belongs_to :discussion

  validates_presence_of :discussion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :discussion_id

  scope :for_user, -> (user) { where(user_id: user.id) }

  def self.for(user: nil, discussion: nil)
    if user.is_logged_in?
      where(user_id: user.id, discussion_id: discussion.id).first_or_initialize do |dr|
        dr.discussion = discussion
        dr.user = user
      end
    else
      new(discussion: discussion)
    end
  end

  def first_read?
    last_read_at.blank?
  end

  def user_or_logged_out_user
    user || LoggedOutUser.new
  end

  def unread_comments_count
    #we count the discussion itself as a comment.. but it is comment 0
    if read_comments_count.nil?
      discussion.comments_count.to_i + 1
    else
      discussion.comments_count.to_i - read_comments_count
    end
  end

  def has_read?(event)
    if last_read_at.present?
      self.last_read_at >= event.updated_at
    else
      false
    end
  end

  def unread_content_exists?
    unread_items_count > 0
  end

  def returning_user_and_unread_content_exist?
    last_read_at.present? and unread_content_exists?
  end

  def unfollow!
    self.following = false
    save!
  end

  def viewed!(age_of_last_read_item = Time.now)
    return if user.nil?
    discussion.viewed!

    if last_read_at.nil? or last_read_at < age_of_last_read_item
      self.read_comments_count = discussion.comments.where('created_at <= ?', age_of_last_read_item).count
      self.read_items_count = discussion.items.where('created_at <= ?', age_of_last_read_item).count
      self.last_read_at = age_of_last_read_item
    end

    save
  end

  def first_unread_page
    per_page = Discussion::PER_PAGE
    remainder = read_items_count % per_page

    if read_items_count == 0
      1
    elsif remainder == 0 && discussion.items_count > read_items_count
      (read_items_count.to_f / per_page).ceil + 1
    else
      (read_items_count.to_f / per_page).ceil
    end
  end

  def unread_items_count
    discussion.items_count - read_items_count
  end
end
