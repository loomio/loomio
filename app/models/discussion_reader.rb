class DiscussionReader < ActiveRecord::Base
  include HasVolume

  belongs_to :user
  belongs_to :discussion

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

  def self.for_model(model, actor = nil)
    self.for(user: actor || model.author, discussion: model.is_a?(Discussion) ? model : model.discussion)
  end

  def author_thread_item!(time)
    set_volume_as_required!
    participate!
    viewed! time
  end

  def set_volume_as_required!
    if user.email_on_participation?
      set_volume! :loud unless volume_is_loud?
    end
  end

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

  def viewed!(age_of_last_read_item = nil)
    return if user.nil?
    read_at = age_of_last_read_item || discussion.last_activity_at

    if self.last_read_at.nil? or (read_at >= self.last_read_at)
      self.last_read_at = read_at
      reset_counts!
    end

    EventBus.broadcast('discussion_reader_viewed!', discussion, user)
  end

  def reset_counts!
    self.read_items_count = read_items.count
    self.read_salient_items_count = read_salient_items.count
    self.last_read_sequence_id = if read_items_count == 0
                                   0
                                 else
                                   read_items.last.sequence_id
                                 end
    save!(validate: false)
  end

  def read_items(time = nil)
    discussion.items.where('events.created_at <= ?', time || last_read_at).chronologically
  end

  def read_salient_items(time = nil)
    discussion.salient_items.where('events.created_at <= ?', time || last_read_at).chronologically
  end

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
