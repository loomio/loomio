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

  def dismiss!
    update_attribute :dismissed_at, Time.zone.now
    EventBus.broadcast('discussion_reader_dismissed!', discussion, user)
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

  def viewed!(read_at = discussion.last_activity_at)
    return unless user

    reset_counts! read_at
    EventBus.broadcast('discussion_reader_viewed!', discussion, user)
  end

  def reset_counts!(read_at = self.last_read_at)
    return if (!read_at && !self.last_read_at) ||                           # no read_at given and no last_read_at is set
              (read_at && self.last_read_at && read_at < self.last_read_at) # last_read_at exists, but is before the given read_at

    assign_attributes(
      last_read_at:             read_at,
      last_read_sequence_id:    self.read_items(read_at).maximum(:sequence_id).to_i,
      read_items_count:         self.read_items(read_at).count,
      read_salient_items_count: self.read_salient_items(read_at).count
    )
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
