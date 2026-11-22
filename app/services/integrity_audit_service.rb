# Read-only checks for relationships PostgreSQL cannot enforce with a foreign key.
module IntegrityAuditService
  POLYMORPHIC_REFERENCES = {
    "ActiveStorage::Attachment" => %i[record_type record_id],
    "Bookmark" => %i[bookmarkable_type bookmarkable_id],
    "Comment" => %i[parent_type parent_id],
    "Notification" => %i[subject_type subject_id],
    "NotificationDelivery" => %i[recipient_type recipient_id],
    "TopicItem" => %i[itemable_type itemable_id],
    "PgSearch::Document" => %i[searchable_type searchable_id],
    "Reaction" => %i[reactable_type reactable_id],
    "Tagging" => %i[taggable_type taggable_id],
    "Task" => %i[record_type record_id],
    "Topic" => %i[topicable_type topicable_id],
    "Translation" => %i[translatable_type translatable_id]
  }.freeze

  # Keep references to retired models visible as legacy records. In particular,
  # a retired Document attachment can still identify a blob used elsewhere.
  POLYMORPHIC_TYPES_RETIRED = {
    "ActiveStorage::Attachment" => %w[Document]
  }.freeze

  DANGLING_RECORD_SCOPES = {
    "Comment.missing_event" => :comments_missing_event,
    "Comment.missing_parent" => :comments_missing_parent,
    "TopicItem.missing_stance" => :events_missing_stance,
    "TopicItem.invalid_root" => :events_invalid_root,
    "Reaction.missing_stance" => :reactions_missing_stance,
    "Bookmark.missing_stance" => :bookmarks_missing_stance,
    "Task.missing_stance" => :tasks_missing_stance,
    "Translation.missing_stance" => :translations_missing_stance,
    "PgSearch::Document.missing_stance" => :search_documents_missing_stance,
    "ActiveStorage::Attachment.missing_stance" => :attachments_missing_stance
  }.freeze

  # ID mode supports before/after checks in rehearsals where writes can be
  # isolated. Counts are the default for production inventory.
  def self.audit_orphan_records(include_ids: false)
    audit = {
      dangling_records: dangling_record_scopes,
      missing_polymorphic_targets: {},
      retired_polymorphic_types: {},
      unresolved_polymorphic_types: {},
      retained_records: { "Subscription.missing_group" => subscriptions_missing_group }
    }

    polymorphic_reference_scopes.each do |key, (category, scope)|
      audit.fetch(category)[key] = scope
    end

    audit.transform_values do |scopes|
      scopes.transform_values do |scope|
        if include_ids
          primary_key = scope.klass.arel_table[scope.klass.primary_key]
          scope.reorder(primary_key).distinct.pluck(primary_key)
        else
          unique_count(scope)
        end
      end
    end
  end

  # Timeline-specific diagnostics used to determine which topics need repair.
  def self.reference_integrity_audit
    invalid_root_topic_items = events_invalid_root
    affected_topic_ids = (
      events_missing_stance.where.not(topic_id: nil).distinct.pluck(:topic_id) +
      invalid_root_topic_items.distinct.pluck(:topic_id) +
      TopicItem.where(itemable_type: "Comment", itemable_id: comments_missing_parent.select(:id))
           .where.not(topic_id: nil)
           .distinct
           .pluck(:topic_id)
    ).uniq

    {
      comments_missing_event: unique_count(comments_missing_event),
      comments_missing_event_with_existing_parent: unique_count(
        comments_missing_event.where.not(id: comments_missing_parent.select(:id))
      ),
      comments_missing_parent: unique_count(comments_missing_parent),
      events_missing_stance: unique_count(events_missing_stance),
      events_invalid_root: unique_count(invalid_root_topic_items),
      reactions_missing_stance: unique_count(reactions_missing_stance),
      bookmarks_missing_stance: unique_count(bookmarks_missing_stance),
      tasks_missing_stance: unique_count(tasks_missing_stance),
      translations_missing_stance: unique_count(translations_missing_stance),
      search_documents_missing_stance: unique_count(search_documents_missing_stance),
      attachments_missing_stance: unique_count(attachments_missing_stance),
      topics_affected: affected_topic_ids.length,
      topic_ids_sample: affected_topic_ids.sort.first(20)
    }
  end

  def self.dangling_record_scopes
    DANGLING_RECORD_SCOPES.transform_values { |method_name| public_send(method_name) }
  end

  def self.comments_missing_event
    Comment
      .joins("LEFT JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id")
      .where('topic_items.id IS NULL')
  end

  def self.comments_missing_parent
    Comment
      .joins("LEFT JOIN discussions parent_discussions ON comments.parent_type = 'Discussion' AND parent_discussions.id = comments.parent_id")
      .joins("LEFT JOIN comments parent_comments ON comments.parent_type = 'Comment' AND parent_comments.id = comments.parent_id")
      .joins("LEFT JOIN outcomes parent_outcomes ON comments.parent_type = 'Outcome' AND parent_outcomes.id = comments.parent_id")
      .joins("LEFT JOIN polls parent_polls ON comments.parent_type = 'Poll' AND parent_polls.id = comments.parent_id")
      .joins("LEFT JOIN stances parent_stances ON comments.parent_type = 'Stance' AND parent_stances.id = comments.parent_id")
      .where(<<~SQL.squish)
        (comments.parent_type = 'Discussion' AND parent_discussions.id IS NULL) OR
        (comments.parent_type = 'Comment' AND parent_comments.id IS NULL) OR
        (comments.parent_type = 'Outcome' AND parent_outcomes.id IS NULL) OR
        (comments.parent_type = 'Poll' AND parent_polls.id IS NULL) OR
        (comments.parent_type = 'Stance' AND parent_stances.id IS NULL)
      SQL
  end

  def self.events_missing_stance
    TopicItem
      .joins("LEFT JOIN stances ON topic_items.itemable_type = 'Stance' AND stances.id = topic_items.itemable_id")
      .where(itemable_type: "Stance", stances: { id: nil })
  end

  def self.events_invalid_root
    TopicItem
      .where.not(topic_id: nil)
      .where(parent_id: nil)
      .where.not(kind: %w[new_discussion poll_created])
  end

  def self.reactions_missing_stance
    Reaction
      .joins("LEFT JOIN stances ON reactions.reactable_type = 'Stance' AND stances.id = reactions.reactable_id")
      .where(reactable_type: "Stance", stances: { id: nil })
  end

  def self.bookmarks_missing_stance
    Bookmark
      .joins("LEFT JOIN stances ON bookmarks.bookmarkable_type = 'Stance' AND stances.id = bookmarks.bookmarkable_id")
      .where(bookmarkable_type: "Stance", stances: { id: nil })
  end

  def self.tasks_missing_stance
    Task
      .joins("LEFT JOIN stances ON tasks.record_type = 'Stance' AND stances.id = tasks.record_id")
      .where(record_type: "Stance", stances: { id: nil })
  end

  def self.translations_missing_stance
    Translation
      .joins("LEFT JOIN stances ON translations.translatable_type = 'Stance' AND stances.id = translations.translatable_id")
      .where(translatable_type: "Stance", stances: { id: nil })
  end

  def self.search_documents_missing_stance
    PgSearch::Document
      .joins("LEFT JOIN stances ON pg_search_documents.searchable_type = 'Stance' AND stances.id = pg_search_documents.searchable_id")
      .where(searchable_type: "Stance", stances: { id: nil })
  end

  def self.attachments_missing_stance
    ActiveStorage::Attachment
      .joins("LEFT JOIN stances ON active_storage_attachments.record_type = 'Stance' AND stances.id = active_storage_attachments.record_id")
      .where(record_type: "Stance", stances: { id: nil })
  end

  def self.subscriptions_missing_group
    Subscription
      .joins('LEFT JOIN groups ON subscriptions.id = groups.subscription_id')
      .where('groups.id IS NULL')
  end

  def self.polymorphic_reference_scopes
    POLYMORPHIC_REFERENCES.merge("PaperTrail::Version" => %i[item_type item_id]).each_with_object({}) do |(class_name, (type_column, id_column)), scopes|
      record_class = class_name.constantize

      record_class.distinct.pluck(type_column).compact.each do |record_type|
        scope = record_class.where(type_column => record_type)
        target = polymorphic_target_class(record_type)
        category = if POLYMORPHIC_TYPES_RETIRED.fetch(class_name, []).include?(record_type)
          :retired_polymorphic_types
        elsif target.nil?
          :unresolved_polymorphic_types
        else
          scope = missing_reference(scope, id_column, target)
          record_class == PaperTrail::Version ? :retained_records : :missing_polymorphic_targets
        end
        scopes["#{class_name}.#{record_type}"] = [category, scope]
      end
    end
  end

  def self.missing_reference(scope, id_column, target)
    source = scope.klass
    source_table = source.quoted_table_name
    target_table = target.quoted_table_name
    source_id = source.connection.quote_column_name(id_column)
    target_id = target.connection.quote_column_name(target.primary_key)

    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM #{target_table} AS reference_target
        WHERE reference_target.#{target_id} = #{source_table}.#{source_id}
      )
    SQL
  end

  def self.polymorphic_target_class(record_type)
    target_class = record_type.safe_constantize
    return unless target_class.is_a?(Class) && target_class < ActiveRecord::Base
    return unless target_class.table_exists? && target_class.primary_key

    target_class
  end

  def self.unique_count(scope)
    scope.unscope(:select, :order).distinct.count(scope.klass.primary_key)
  end
end
