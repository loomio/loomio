class TopicHeadingsService
  FIELDS = {'Discussion' => :description, 'Poll' => :details, 'Comment' => :body,
            'Stance' => :reason, 'Outcome' => :statement}.freeze

  def self.items(topic)
    # Reuse the content visibility scope so removed content and descendants of
    # removed polls do not become navigation entries. Votes have their own rules.
    topic.items.where(id: TopicItem.tags_visible.select(:id))
      .or(topic.items.where(kind: %w[stance_created stance_updated], itemable_type: 'Stance'))
  end

  # Build a compact outline without sending bodies or loading the whole thread.
  # Each page preloads vote/outcome polls, reads the viewer's votes in one query,
  # and uses only cached translations. Headings must obey presentation visibility
  # too: until-vote reasons must not appear before the viewer has voted.
  def self.sections(items, user)
    records = items.map(&:itemable)
    poll_children = records.grep(Stance) + records.grep(Outcome)
    ActiveRecord::Associations::Preloader.new(records: poll_children, associations: :poll).call
    polls = poll_children.map(&:poll).uniq(&:id)
    voted_ids = Stance.latest.cast.where(poll_id: polls.map(&:id), participant_id: user.id).pluck(:poll_id)
    translations = cached_translations(records, user)

    items.filter_map do |item|
      record = item.itemable
      field = FIELDS.fetch(item.itemable_type)
      next if record.discarded?
      if record.is_a?(Stance)
        next if record.revoked_at || record.redacted_at || !record.cast_at || record.poll.discarded?
        next if record.poll.anonymous? || !record.poll.closing_at
        next unless record.poll.results_visible?(voted: voted_ids.include?(record.poll_id))
      end
      translation = translations[[item.itemable_type, record.id]]
      text = translation ? translation.fields[field.to_s] : record.public_send(field)
      format = translation ? 'html' : record.public_send("#{field}_format")
      {topic_item_id: item.id, sequence_id: item.sequence_id, position_key: item.position_key,
       field: field, model_type: record.model_name.singular, model_id: record.id,
       poll_id: record.is_a?(Stance) || record.is_a?(Outcome) ? record.poll_id : nil,
       headings: HasRichText.headings(text, format)}
    end
  end

  def self.cached_translations(records, user)
    return {} unless user.is_logged_in? && user.auto_translate && TranslationService.available?

    Translation.where(language: TranslationService.locale_for_google(user.locale),
      translatable_type: records.map { |record| record.class.base_class.name }.uniq,
      translatable_id: records.map(&:id)).index_by { |translation| [translation.translatable_type, translation.translatable_id] }
  end
  private_class_method :cached_translations
end
