class DiscussionReader < ActiveRecord::Base

  belongs_to :user
  belongs_to :discussion

  validates_presence_of :discussion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :discussion_id

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
      discussion.comments_count.to_i + 1
    else
      discussion.comments_count.to_i - read_comments_count
    end
  end

  def unread?(time)
    if self.last_read_at == nil
      false
    else
      self.last_read_at < time
    end
  end

  def unread_content_exists?
    unread_items_count > 0
  end

  def returning_user_and_unread_content_exist?
    last_read_at.present? and unread_content_exists?
  end

  def self.for(discussion, user)
    self.first_or_create(discussion_id: discussion.id, user_id: user.id)
  end

  def unfollow!
    self.following = false
    save!
  end

  def viewed!(age_of_last_read_item = Time.now)
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
