class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, discussion_readers)
    super model,
      user: actor,
      custom_fields: {discussion_reader_ids: discussion_readers.pluck(:id)}
  end

  private

  def discussion_readers
    DiscussionReader.where(id: discussion_readers.pluck(:id))
  end

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.distinct.active.joins('LEFT OUTER JOIN discussion_readers dr on dr.user_id = users.id').where('dr.id IN (?)', custom_fields['discussion_reader_ids'])
  end
end
