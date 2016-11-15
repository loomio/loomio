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

  def update_reader(read_at: nil, volume: nil, participate: false, dismiss: false)
    viewed!(read_at, persist: false)    if read_at
    set_volume!(volume, persist: false) if volume && (volume != :loud || user.email_on_participation?)
    participate!(persist: false)        if participate
    dismiss!(persist: false)            if dismiss
    save(validate: false)               if changed?
  end

  def viewed!(read_at, persist: true)
    return if self.last_read_at && self.last_read_at > read_at
    assign_attributes(read_attributes(read_at))
    EventBus.broadcast('discussion_reader_viewed!', discussion, user)
    save if persist
  end

  def dismiss!(persist: true)
    self.dismissed_at = Time.zone.now
    EventBus.broadcast('discussion_reader_dismissed!', discussion, user)
    save if persist
  end

  def participate!(persist: true)
    self.participating = true
    save if persist
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

  private

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

  def membership
    @membership ||= discussion.group.membership_for(user)
  end
end
