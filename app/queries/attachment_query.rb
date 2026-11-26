class AttachmentQuery
  def self.find(group_ids, query, limit, offset, user:, sort: nil)
    return ActiveStorage::Attachment.none if group_ids.blank?

    sql = union_sql(group_ids, query, user: user)
    clamped_limit = limit.to_i.clamp(1, 100)
    clamped_offset = [ offset.to_i, 0 ].max

    case sort
    when 'oldest'
      ids = ApplicationRecord.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "SELECT id FROM (#{sql}) matching_attachments ORDER BY id ASC LIMIT :limit OFFSET :offset",
          { limit: clamped_limit, offset: clamped_offset }
        ])
      )
      return ActiveStorage::Attachment.none if ids.empty?

      ActiveStorage::Attachment.joins(:blob).where(id: ids).order(id: :asc)
    when 'name'
      ids = ApplicationRecord.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "SELECT a.id FROM active_storage_attachments a
           INNER JOIN active_storage_blobs b ON b.id = a.blob_id
           WHERE a.id IN (#{sql})
           ORDER BY LOWER(b.filename) ASC, a.id ASC
           LIMIT :limit OFFSET :offset",
          { limit: clamped_limit, offset: clamped_offset }
        ])
      )
      return ActiveStorage::Attachment.none if ids.empty?

      ActiveStorage::Attachment.joins(:blob).where(id: ids).order(Arel.sql("LOWER(active_storage_blobs.filename) ASC, active_storage_attachments.id ASC"))
    else
      ids = ApplicationRecord.connection.select_values(
        ActiveRecord::Base.sanitize_sql_array([
          "SELECT id FROM (#{sql}) matching_attachments ORDER BY id DESC LIMIT :limit OFFSET :offset",
          { limit: clamped_limit, offset: clamped_offset }
        ])
      )
      return ActiveStorage::Attachment.none if ids.empty?

      ActiveStorage::Attachment.joins(:blob).where(id: ids).order(id: :desc)
    end
  end

  def self.count(group_ids, query, user:)
    return 0 if group_ids.blank?

    sql = union_sql(group_ids, query, user: user)
    ApplicationRecord.connection.select_value("SELECT COUNT(*) FROM (#{sql}) matching_attachments").to_i
  end

  def self.union_sql(group_ids, query, user:)
    scopes = [
      base_scope(query)
        .joins("INNER JOIN groups ON active_storage_attachments.record_type = 'Group' AND active_storage_attachments.record_id = groups.id")
        .where(groups: { id: group_ids }),

      base_scope(query)
        .joins("INNER JOIN comments ON active_storage_attachments.record_type = 'Comment' AND active_storage_attachments.record_id = comments.id")
        .joins("INNER JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id")
        .joins("INNER JOIN topics ON topics.id = topic_items.topic_id")
        .where(topics: { group_id: group_ids, discarded_at: nil }, comments: { discarded_at: nil }),

      base_scope(query)
        .joins("INNER JOIN outcomes ON active_storage_attachments.record_type = 'Outcome' AND active_storage_attachments.record_id = outcomes.id")
        .joins("INNER JOIN polls outcomes_polls ON outcomes_polls.id = outcomes.poll_id")
        .joins("INNER JOIN topics outcomes_topics ON outcomes_topics.id = outcomes_polls.topic_id")
        .where("outcomes_topics.group_id IN (:group_ids) AND outcomes_polls.discarded_at IS NULL", group_ids: group_ids),

      stance_scope(group_ids, query, user: user),

      base_scope(query)
        .joins("INNER JOIN discussions ON active_storage_attachments.record_type = 'Discussion' AND active_storage_attachments.record_id = discussions.id")
        .joins("INNER JOIN topics discussions_topics ON discussions_topics.id = discussions.topic_id")
        .where("discussions_topics.group_id IN (:group_ids) AND discussions.discarded_at IS NULL", group_ids: group_ids),

      base_scope(query)
        .joins("INNER JOIN polls ON active_storage_attachments.record_type = 'Poll' AND polls.id = active_storage_attachments.record_id")
        .joins("INNER JOIN topics polls_topics ON polls_topics.id = polls.topic_id")
        .where("polls_topics.group_id IN (:group_ids) AND polls.discarded_at IS NULL", group_ids: group_ids)
    ].compact

    scopes.map { |s| s.select("active_storage_attachments.id").to_sql }.join(" UNION ALL ")
  end
  private_class_method :union_sql

  def self.base_scope(query)
    scope = ActiveStorage::Attachment.where(name: :files)
    if query.present?
      scope = scope.joins(:blob).where("active_storage_blobs.filename ILIKE ?", "%#{query}%")
    end
    scope
  end
  private_class_method :base_scope

  def self.stance_scope(group_ids, query, user:)
    candidate_poll_ids = base_scope(query)
      .joins("INNER JOIN stances ON active_storage_attachments.record_type = 'Stance' AND active_storage_attachments.record_id = stances.id")
      .joins("INNER JOIN polls stances_polls ON stances_polls.id = stances.poll_id")
      .joins("INNER JOIN topics stances_topics ON stances_topics.id = stances_polls.topic_id")
      .where("stances_topics.group_id IN (:group_ids) AND stances_polls.discarded_at IS NULL AND stances.revoked_at IS NULL", group_ids: group_ids)
      .distinct
      .pluck("stances_polls.id")
    return nil if candidate_poll_ids.empty?

    candidate_polls = PollQuery.visible_to(user: user, group_ids: group_ids).where(id: candidate_poll_ids).reject(&:anonymous?)
    voted_poll_ids = if candidate_polls.any?
      Stance.latest.cast.where(poll_id: candidate_polls.map(&:id), participant_id: user.id).pluck(:poll_id).to_set
    else
      Set.new
    end
    visible_poll_ids = candidate_polls.select { |poll| poll.results_visible?(voted: voted_poll_ids.include?(poll.id)) }.map(&:id)

    base_scope(query)
      .joins("INNER JOIN stances ON active_storage_attachments.record_type = 'Stance' AND active_storage_attachments.record_id = stances.id")
      .joins("INNER JOIN polls stances_polls ON stances_polls.id = stances.poll_id")
      .joins("INNER JOIN topics stances_topics ON stances_topics.id = stances_polls.topic_id")
      .where("stances_topics.group_id IN (:group_ids) AND stances_polls.discarded_at IS NULL AND stances.revoked_at IS NULL", group_ids: group_ids)
      .where("stances.participant_id = :user_id OR stances_polls.id IN (:visible_poll_ids)",
             user_id: user.id, visible_poll_ids: visible_poll_ids.presence || [ -1 ])
  end
  private_class_method :stance_scope
end
