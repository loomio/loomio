class AttachmentQuery
  def self.find(group_ids, query, limit, offset)
    puts :group_ids, group_ids.inspect
    ids = []
    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN groups ON active_storage_attachments.record_type = 'Group' AND active_storage_attachments.record_id = groups.id").
      where('groups.id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN comments ON active_storage_attachments.record_type = 'Comment' AND active_storage_attachments.record_id = comments.id").
      joins("LEFT OUTER JOIN discussions comments_discussions ON comments_discussions.id = comments.discussion_id").
      where('comments_discussions.group_id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN outcomes ON active_storage_attachments.record_type = 'Outcome' AND active_storage_attachments.record_id = outcomes.id").
      joins("LEFT OUTER JOIN polls outcomes_polls ON outcomes_polls.id = outcomes.poll_id").
      where('outcomes_polls.group_id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN stances  ON active_storage_attachments.record_type = 'Stance'  AND active_storage_attachments.record_id = stances.id").
      joins("LEFT OUTER JOIN polls stances_polls ON stances_polls.id = stances.id").
      where('stances_polls.group_id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN discussions ON active_storage_attachments.record_type = 'Discussion' AND discussions.id = active_storage_attachments.record_id").
      where('discussions.group_id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ids.concat ActiveStorage::Attachment.joins(:blob).
      joins("LEFT OUTER JOIN polls ON active_storage_attachments.record_type = 'Poll' AND polls.id = active_storage_attachments.record_id").
      where('polls.group_id IN (:group_ids)', group_ids: group_ids).
      where('active_storage_attachments.name': :files).
      where("active_storage_blobs.filename ilike ?", "%#{query}%").limit(limit).offset(offset).order('id desc').pluck(:id)

    ActiveStorage::Attachment.joins(:blob).where(id: ids).order('id desc')
  end
end
