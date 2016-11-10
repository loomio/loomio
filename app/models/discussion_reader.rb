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
    self.for(user: actor || model.author, discussion: model.discussion)
  end

  def viewed!(read_at = discussion.last_activity_at)
    update_reader(read_at: read_at)
  end

  def dismiss!
    update_reader(dismissed: true)
  end

  def update_reader(read_at: nil, participate: false, dismissed: false, volume: nil)
    assign_attributes(read_attributes(read_at))    if should_update_counts?(read_at)
    assign_attributes(volume: volume)              if should_update_volume?(volume)
    assign_attributes(participating: true)         if participate
    assign_attributes(dismissed_at: Time.zone.now) if dismissed
    save(validate: false)                          if changed?

    EventBus.broadcast('discussion_reader_viewed!',    discussion, user) if should_update_counts?(read_at)
    EventBus.broadcast('discussion_reader_dismissed!', discussion, user) if dismissed
  end

  def read_attributes(read_at)
    @read_attributes ||= begin
      read_items         = discussion.items.where('events.created_at <= ?', read_at)
      read_salient_items = discussion.salient_items.where('events.created_at <= ?', read_at)
      {
        last_read_at:             read_at,
        last_read_sequence_id:    read_items.maximum(:sequence_id).to_i,
        read_items_count:         read_items.count,
        read_salient_items_count: read_salient_items.count
      }
    end
  end

  def should_update_counts?(read_at = self.last_read_at)
    (read_at && !self.last_read_at) ||                           # new read time is given and no existing read time exists
    (read_at && self.last_read_at && read_at > self.last_read_at) # last read time exists, but is before the new read time
  end

  def should_update_volume?(volume)
    volume_is_valid?(volume) && (volume != :loud || user.email_on_participation?)
  end

  def volume
    if persisted?
      super || membership&.volume || 'normal'
    else
      membership.volume
    end
  end

  def discussion_reader_volume
    # Crazy James says: necessary in order to get a string back from the volume enum, rather than an integer
    self.class.volumes.invert[self[:volume]]
  end

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
