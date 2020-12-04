class AttachmentQuery
  def self.find(group_ids)
    puts :group_ids, group_ids.inspect
    ActiveStorage::Attachment.distinct.joins(:blob).
      joins("LEFT OUTER JOIN groups   ON active_storage_attachments.record_type = 'Group'   AND active_storage_attachments.record_id = groups.id").
      joins("LEFT OUTER JOIN comments ON active_storage_attachments.record_type = 'Comment' AND active_storage_attachments.record_id = comments.id").
      joins("LEFT OUTER JOIN discussions comments_discussions ON comments_discussions.id = comments.discussion_id").
      joins("LEFT OUTER JOIN outcomes ON active_storage_attachments.record_type = 'Outcome' AND active_storage_attachments.record_id = outcomes.id").
      joins("LEFT OUTER JOIN polls outcomes_polls ON outcomes_polls.id = outcomes.poll_id").
      joins("LEFT OUTER JOIN stances  ON active_storage_attachments.record_type = 'Stance'  AND active_storage_attachments.record_id = stances.id").
      joins("LEFT OUTER JOIN polls stances_polls ON stances_polls.id = stances.id").
      joins("LEFT OUTER JOIN discussions ON active_storage_attachments.record_type = 'Discussion' AND discussions.id = active_storage_attachments.record_id").
      joins("LEFT OUTER JOIN polls ON active_storage_attachments.record_type = 'Poll' AND polls.id = active_storage_attachments.record_id").
      where('active_storage_attachments.name': :files).
      where('groups.id IN (:group_ids) OR
             comments_discussions.group_id IN (:group_ids) OR
             outcomes_polls.group_id IN (:group_ids) OR
             stances_polls.group_id IN (:group_ids) OR
             discussions.group_id IN (:group_ids) OR
             polls.group_id IN (:group_ids)', group_ids: group_ids)
  end
end
