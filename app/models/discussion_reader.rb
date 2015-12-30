class DiscussionReader < ActiveRecord::Base
  include HasVolume

  belongs_to :user
  belongs_to :discussion

  scope :for_user, -> (user) { where(user_id: user.id) }

  def self.for(user: , discussion: )
    if (!user.nil?) and user.is_logged_in?
      begin
        find_or_create_by(user_id: user.id, discussion_id: discussion.id)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    else
      new(discussion: discussion)
    end
  end

  def self.for_comment(comment:)
    self.for(user: comment.author, discussion: comment.discussion)
  end

  def self.for_comment_vote(comment_vote:)
    self.for(user: comment_vote.user, discussion: comment_vote.comment.discussion)
  end

  def author_thread_item!(time)
    set_volume_as_required!
    participate!
    viewed! time
  end
  EventBus.listen('comment_create') { |comment| for_comment(comment: comment).author_thread_item!(comment.created_at) }

  def set_volume_as_required!
    if user.email_on_participation?
      set_volume! :loud unless volume_is_loud?
    end
  end
  EventBus.listen('comment_like') { |comment_vote| for_comment_vote(comment_vote: comment_vote).set_volume_as_required! }

  def participate!
    update_attribute :participating, true
  end

  def volume
    if persisted?
      super || membership && membership.volume || 'normal'
    else
      membership.volume
    end
  end

  def discussion_reader_volume
    # Crazy James says: necessary in order to get a string back from the volume enum, rather than an integer
    self.class.volumes.invert[self[:volume]]
  end

  def first_read?
    last_read_at.blank?
  end

  def unread_comments_count
    #we count the discussion itself as a comment.. but it is comment 0
    if last_read_at.blank?
      discussion.comments_count.to_i + 1
    else
      discussion.comments_count.to_i - read_comments_count
    end
  end

  def unread_items_count
    discussion.items_count - read_items_count
  end

  def unread_activity_count
    if last_read_at.blank?
      discussion.salient_items_count + 1
    else
      discussion.salient_items_count - read_salient_items_count
    end
  end

  def has_read?(event)
    if last_read_at.present?
      self.last_read_at >= event.created_at
    else
      false
    end
  end

  def unread_activity?
    last_read_at.nil? || (discussion.last_activity_at > last_read_at)
  end

  def viewed!(age_of_last_read_item = nil)
    return if user.nil?
    read_at = age_of_last_read_item || discussion.last_activity_at

    if self.last_read_at.nil? or (read_at >= self.last_read_at)
      self.last_read_at = read_at
      reset_counts!
    end

    publish!
  end

  def publish!
    publish_data = Simple::DiscussionSerializer.new(discussion, scope: { reader_cache: reader_cache })
    MessageChannelService.publish(publish_data.as_json, to: user)
  end

  def reset_comment_counts
    self.read_comments_count = read_comments.count
  end

  def reset_comment_counts!
    reset_comment_counts
    save!(validate: false)
  end

  def reset_non_comment_counts
    self.read_items_count = read_items.count
    self.read_salient_items_count = read_salient_items.count
    self.last_read_sequence_id = if read_items_count == 0
                                   0
                                 else
                                   read_items.last.sequence_id
                                 end
  end

  def reset_non_comment_counts!
    reset_non_comment_counts
    save!(validate: false)
  end

  def reset_counts!
    reset_comment_counts
    reset_non_comment_counts
    save!(validate: false)
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

  def read_comments(time = nil)
    discussion.comments.where('comments.created_at <= ?', time || last_read_at).chronologically
  end

  def read_items(time = nil)
    discussion.items.where('events.created_at <= ?', time || last_read_at).chronologically
  end

  def read_salient_items(time = nil)
    discussion.salient_items.where('events.created_at <= ?', time || last_read_at).chronologically
  end

  private
  def membership
    discussion.group.membership_for(user)
  end

  def reader_cache
    @reader_cache ||= DiscussionReaderCache.new(user: self.user, discussions: Array(self.discussion))
  end
end
