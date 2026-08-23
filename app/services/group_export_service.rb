class GroupExportService
  RELATIONS = %w[
    all_users
    all_topic_items
    all_notifications
    all_notification_deliveries
    all_reactions
    all_tags
    poll_templates
    discussion_templates
    memberships
    membership_requests
    discussions
    topics
    exportable_polls
    exportable_poll_options
    exportable_anonymous_ballots
    exportable_anonymous_ballot_choices
    exportable_anonymous_poll_voters
    exportable_legacy_anonymous_vote_reasons
    exportable_outcomes
    exportable_stances
    exportable_stance_choices
    poll_stance_receipts
    topic_readers
    comments
  ]

  JSON_PARAMS = {
    groups:      {except: [:token], methods: []},
    users:       {except: [:password_digest,
                           :email_api_key,
                           :secret_token,
                           :unsubscribe_token] }
  }.with_indifferent_access.freeze

  BACK_REFERENCES = {
    outcomes: {
      topic_items: %w[itemable],
      notifications: %w[subject]
    },
    comments: {
      comments: %w[parent],
      topic_items: %w[itemable],
      reactions: %w[reactable],
      notifications: %w[subject]
    },
    discussions: {
      topics: %w[topicable],
      comments: %w[parent],
      topic_items: %w[itemable],
      reactions: %w[reactable],
      notifications: %w[subject]
    },
    topics: {
      discussions: %w[topic_id],
      polls: %w[topic_id],
      topic_items: %w[topic_id],
      topic_readers: %w[topic_id]
    },
    topic_items: {
      topic_items: %w[parent_id]
    },
    notifications: {
      notification_deliveries: %w[notification_id]
    },
    memberships: {
      notifications: %w[subject]
    },
    reactions: {
      notifications: %w[subject]
    },
    groups: {
      memberships: %w[group_id],
      topics: %w[group_id],
      tags: %w[group_id],
      webhooks: %w[group_id],
      topic_items: %w[itemable],
      notifications: %w[subject],
      groups: %w[parent_id],
      poll_templates: %w[group_id],
      discussion_templates: %w[group_id]
    },
    poll_options: {
      stance_choices: %w[poll_option_id],
      anonymous_ballot_choices: %w[poll_option_id],
      topic_items: %w[itemable]
    },
    anonymous_ballots: {
      anonymous_ballot_choices: %w[anonymous_ballot_id],
      legacy_anonymous_vote_reasons: %w[anonymous_ballot_id]
    },
    stances: {
      comments: %w[parent],
      stance_choices: %w[stance_id],
      topic_items: %w[itemable],
      reactions: %w[reactable],
      notifications: %w[subject]
    },
    tasks: {
      tasks_users: %w[task_id],
      topic_items: %w[itemable]
    },
    polls: {
      anonymous_ballots: %w[poll_id],
      anonymous_poll_voters: %w[poll_id],
      comments: %w[parent],
      topics: %w[topicable],
      stance_receipts: %w[poll_id],
      stances: %w[poll_id],
      poll_options: %w[poll_id],
      outcomes: %w[poll_id],
      topic_items: %w[itemable],
      reactions: %w[reactable],
      notifications: %w[subject]
    },
    users: {
      anonymous_poll_voters: %w[voter_id inviter_id],
      stance_receipts: %w[voter_id inviter_id],
      topic_items: %w[itemable user_id],
      discussions: %w[author_id discarded_by],
      discussion_templates: %w[author_id],
      poll_templates: %w[author_id],
      attachments: %w[user_id],
      comments: %w[user_id discarded_by] ,
      topic_readers: %w[user_id inviter_id],
      groups: %w[creator_id],
      membership_requests: %w[requestor_id responder_id],
      memberships: %w[user_id inviter_id],
      notifications: %w[actor_id],
      notification_deliveries: %w[recipient],
      outcomes: %w[author_id],
      polls: %w[author_id discarded_by],
      reactions: %w[user_id],
      stances: %w[participant_id inviter_id],
      subscriptions: %w[owner_id],
      tasks: %w[doer_id author_id],
      tasks_users: %w[user_id],
      versions: %w[whodunnit],
      webhooks: %w[author_id]
    }
  }.with_indifferent_access.freeze

  # Invert BACK_REFERENCES so we can translate a record's own foreign keys before
  # insert: FORWARD_REFERENCES[source_table][column] => target_table.
  FORWARD_REFERENCES = BACK_REFERENCES.each_with_object({}) do |(target_table, refs), fwd|
    refs.each_pair do |source_table, columns|
      columns.each { |column| (fwd[source_table] ||= {})[column] = target_table }
    end
  end.with_indifferent_access.freeze

  # Polymorphic association columns: their target table is resolved at runtime from
  # the record's stored "<column>_type", not from FORWARD_REFERENCES' target_table.
  POLYMORPHIC_COLUMNS = %w[itemable reactable topicable parent recipient subject].freeze

  def self.export_direct_topics(group_id)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids
    author_ids = Membership.where(group_id: group_ids).pluck(:user_id).uniq
    topics = Topic.joins_topicables
                  .where(group_id: nil)
                  .where("discussions.author_id IN (:author_ids) OR polls.author_id IN (:author_ids)", author_ids: author_ids)
    filename = export_filename_for("invite-only-topics-for-group-#{group_id.to_i}")
    ids = Hash.new { |hash, key| hash[key] = [] }
    anonymous_ballot_ids = {}

    File.open(filename, 'w') do |file|
      topics.find_each(batch_size: 20000) do |topic|
        export_direct_topic(topic, file, ids, anonymous_ballot_ids)
      end
    end

    filename
  end

  def self.export_direct_topic(topic, file, ids, anonymous_ballot_ids = {})
    export_records(topic.members, file, ids, anonymous_ballot_ids)
    puts_record(topic, file, ids, anonymous_ballot_ids)
    puts_record(topic.topicable, file, ids, anonymous_ballot_ids) if topic.topicable

    polls = Poll.where(topic_id: topic.id).where("anonymous = false OR closed_at is not null")
    outcomes = Outcome.where(poll_id: polls.select(:id))
    stances = Stance.where(poll_id: polls.select(:id))
    anonymous_ballots = AnonymousBallot.where(poll_id: polls.select(:id))
    comments = topic.comments

    [
      polls,
      PollOption.where(poll_id: polls.select(:id)),
      anonymous_ballots,
      AnonymousBallotChoice.where(anonymous_ballot_id: anonymous_ballots.select(:id)),
      AnonymousPollVoter.where(poll_id: polls.select(:id)),
      LegacyAnonymousVoteReason.where(anonymous_ballot_id: anonymous_ballots.select(:id)),
      outcomes,
      stances,
      StanceChoice.where(stance_id: stances.select(:id)),
      StanceReceipt.where(poll_id: polls.select(:id)),
      topic.items,
      topic.topic_readers,
      comments
    ].each do |records|
      export_records(records, file, ids, anonymous_ballot_ids)
    end

    export_records(reactions_for_records([topic.topicable].compact + polls.to_a + stances.to_a + outcomes.to_a + comments.to_a), file, ids, anonymous_ballot_ids)

    [
      topic.topicable&.files,
      topic.topicable&.image_files,
      comments.map(&:files),
      comments.map(&:image_files),
      polls.map(&:files),
      polls.map(&:image_files),
      outcomes.map(&:files),
      outcomes.map(&:image_files)
    ].compact.flatten.uniq.each do |attachment|
      puts_attachment(attachment, file)
    end
  end

  def self.export_records(records, file, ids, anonymous_ballot_ids)
    options = {batch_size: 20000}
    if records.klass == AnonymousBallotChoice
      options.merge!(cursor: [:anonymous_ballot_id, :poll_option_id], order: [:asc, :asc])
    end

    records.find_each(**options) do |record|
      puts_record(record, file, ids, anonymous_ballot_ids)
    end
  end

  def self.reactions_for_records(records)
    relations = records.group_by { |record| record.class.to_s }.map do |reactable_type, grouped_records|
      Reaction.where(reactable_type: reactable_type, reactable_id: grouped_records.map(&:id))
    end

    relations.reduce { |relation, next_relation| relation.or(next_relation) } || Reaction.none
  end

  def self.export(groups, group_name)
    filename = export_filename_for(group_name)
    ids = Hash.new { |hash, key| hash[key] = [] }
    anonymous_ballot_ids = {}
    File.open(filename, 'w') do |file|
      groups.each do |group|
        puts_record(group, file, ids, anonymous_ballot_ids)
        RELATIONS.each do |relation|
          # puts "Exporting: #{relation}"
          export_records(group.send(relation), file, ids, anonymous_ballot_ids)
        end

        user_attachments = group.all_users.map(&:uploaded_avatar_attachment)
        own_attachments = [group.cover_photo_attachment,
                           group.logo_attachment,
                           group.files_attachments,
                           group.image_files_attachments]

        related_attachments = [group.comment_files,
                              group.comment_image_files,
                              group.discussion_files,
                              group.discussion_image_files,
                              group.poll_files,
                              group.poll_image_files,
                              group.outcome_files,
                              group.outcome_image_files,
                              group.subgroup_files,
                              group.subgroup_image_files,
                              group.subgroup_cover_photos,
                              group.subgroup_logos]

        (user_attachments + own_attachments + related_attachments).
        compact.flatten.uniq.each do |attachment|
          puts_attachment(attachment, file)
        end
      end
    end
    filename
  end

  def self.export_filename_for(group_name)
    "/tmp/#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}_#{group_name.parameterize}.json"
  end

  def self.puts_attachment(attachment, file)
    download_path = Rails.application.routes.url_helpers.rails_blob_path(attachment, only_path: true)
    obj = {
      id: attachment.id,
      host: ENV['CANONICAL_HOST'],
      record_type: attachment.record_type,
      record_id: attachment.record_id,
      name: attachment.name,
      filename: attachment.filename,
      content_type: attachment.content_type,
      path: download_path,
      url: "https://#{ENV['CANONICAL_HOST']}#{download_path}"
    }

    file.puts({table: 'attachments', record: obj}.to_json)
  end

  def self.puts_record(record, file, ids, anonymous_ballot_ids = {})
    table = record.class.table_name
    identity = export_record_identity(record)
    return if ids[table].include?(identity)
    ids[table] << identity
    file.puts({table: table, record: export_archive_record(record, table, anonymous_ballot_ids)}.to_json)
  end

  def self.export_record_identity(record)
    return [record.anonymous_ballot_id, record.poll_option_id] if record.is_a?(AnonymousBallotChoice)

    record.id
  end

  def self.export_archive_record(record, table, anonymous_ballot_ids)
    json = export_record(record, table)

    case record
    when AnonymousBallot
      json['id'] = anonymous_ballot_export_id(record.id, anonymous_ballot_ids)
    when AnonymousBallotChoice, LegacyAnonymousVoteReason
      json['anonymous_ballot_id'] = anonymous_ballot_export_id(record.anonymous_ballot_id, anonymous_ballot_ids)
    end

    json
  end

  def self.anonymous_ballot_export_id(id, anonymous_ballot_ids)
    anonymous_ballot_ids[id] ||= SecureRandom.uuid
  end

  def self.export_record(record, table)
    record.as_json(JSON_PARAMS[table])
  end

  def self.import(filename_or_url, reset_keys: false)
    if URI.parse(filename_or_url).class == URI::Generic
      datas = File.open(filename_or_url).read.split("\n").map { |line| JSON.parse(line) }
    else
      datas = URI.parse(filename_or_url).read.split("\n").map { |line| JSON.parse(line) }
    end

    datas_by_table = datas.group_by { |data| data['table'] }
    tables = datas_by_table.keys - ['attachments']

    ActiveRecord::Base.transaction do
      migrate_ids = build_migrate_ids(datas_by_table, tables)
      existing_user_ids = User.where(id: migrate_ids['users']&.values || []).pluck(:id)
      existing_tag_ids = Tag.where(id: migrate_ids['tags']&.values || []).pluck(:id)

      tables.each do |table|
        klass = table.classify.constantize
        pk = klass.primary_key
        inserted_tag_ids = Set.new
        datas_by_table[table].each do |data|
          old_id = data['record'][pk]
          new_id = migrate_ids[table][old_id]
          next if table == 'users' && existing_user_ids.include?(new_id)
          next if table == 'tags' && existing_tag_ids.include?(new_id)
          next if table == 'tags' && !inserted_tag_ids.add?(new_id)

          attrs = data['record'].deep_dup
          translate_foreign_keys!(attrs, table, migrate_ids)
          attrs[pk] = new_id if pk
          translate_notification_payload!(attrs, migrate_ids) if table == 'notifications'
          record = klass.new(attrs)
          prepare_record_for_import!(record, table, data['record'], klass, reset_keys)
          klass.import([record], validate: false)
        end
      end

      # if tables.include?('attachments')
      #   datas.each do |data|
      #     next unless (data['table'] == 'attachments')
      #     table = data['record']['record_type'].tableize
      #     new_id = migrate_ids[table][data['record']['record_id']]
      #     DownloadAttachmentWorker.perform_later(data['record'], new_id)
      #   end
      # end

      datas.each do |data|
        if data['table'] == 'polls'
          new_id = migrate_ids['polls'][data['record']['id']]
          Poll.find(new_id).update_counts!
          Poll.find(new_id).stances.each(&:update_option_scores!)
        end
      end
    end

    nil
  end

  # Reserve a block of fresh primary-key ids from the table's sequence without
  # inserting any rows. nextval advances the sequence past the block it returns,
  # so subsequent real inserts are safe.
  def self.reserve_ids(klass, count)
    return [] if count.zero?
    conn = klass.connection
    seq = conn.select_value("SELECT pg_get_serial_sequence(#{conn.quote(klass.table_name)}, #{conn.quote(klass.primary_key)})")
    raise "no sequence for #{klass.table_name}.#{klass.primary_key}" unless seq

    max_id = klass.unscoped.maximum(klass.primary_key).to_i
    last_value = conn.select_value("SELECT last_value FROM #{conn.quote_table_name(seq)}").to_i
    conn.select_value("SELECT setval(#{conn.quote(seq)}, #{[max_id, last_value].max})")
    conn.select_values("SELECT nextval(#{conn.quote(seq)}) FROM generate_series(1, #{count.to_i})").map(&:to_i)
  end

  # Look up a foreign key's migrated id, falling back to the original id when
  # the target table wasn't part of this import (e.g. importing into an
  # existing group without re-creating the group record itself).
  def self.resolve_id(target_table, old_id, migrate_ids)
    map = migrate_ids[target_table]
    map&.has_key?(old_id) ? map[old_id] : old_id
  end

  def self.build_migrate_ids(datas_by_table, tables)
    tables.each_with_object({}.with_indifferent_access) do |table, migrate_ids|
      klass = table.classify.constantize
      pk = klass.primary_key
      records = datas_by_table[table]
      migrate_ids[table] = {}.with_indifferent_access

      if pk.blank?
        next
      elsif table == 'users'
        existing_users_by_email = User.where(email: records.map { |data| data['record']['email'] }.compact)
                                      .index_by { |user| user.email.to_s.downcase }
        redacted_user_keys = records.filter_map do |data|
          data['record']['key'] if data['record']['email'].blank?
        end
        existing_redacted_users_by_key = User.where(email: nil, key: redacted_user_keys).index_by(&:key)
        existing_user_for = lambda do |data|
          if data['record']['email'].present?
            existing_users_by_email[data['record']['email'].downcase]
          else
            existing_redacted_users_by_key[data['record']['key']]
          end
        end
        new_records = records.reject { |data| existing_user_for.call(data) }
        reserved_ids = reserve_ids(klass, new_records.length)

        records.each do |data|
          old_id = data['record'][pk]
          existing_user = existing_user_for.call(data)
          migrate_ids[table][old_id] = existing_user ? existing_user.id : reserved_ids.shift
        end
      elsif table == 'tags'
        # Source data can itself contain multiple tag rows that collide once
        # inserted, since Tag#name is citext (case-insensitive) and normalizes
        # by stripping whitespace on assignment. Key on the same normalization
        # TagService uses so we dedupe exactly what the DB will treat as identical.
        tag_key = ->(data) { [resolve_id('groups', data['record']['group_id'], migrate_ids), TagService.normalized_tag_name(data['record']['name'])] }
        resolved_group_ids = records.map { |data| tag_key.call(data).first }.uniq
        existing_tags_by_key = Tag.where(group_id: resolved_group_ids).index_by { |tag| [tag.group_id, TagService.normalized_tag_name(tag.name)] }

        unique_keys = records.map { |data| tag_key.call(data) }.uniq
        new_keys = unique_keys.reject { |key| existing_tags_by_key.key?(key) }
        new_id_by_key = new_keys.zip(reserve_ids(klass, new_keys.length)).to_h

        records.each do |data|
          old_id = data['record'][pk]
          key = tag_key.call(data)
          migrate_ids[table][old_id] = existing_tags_by_key[key]&.id || new_id_by_key[key]
        end
      elsif (target_table = FORWARD_REFERENCES.dig(table, pk)) && migrate_ids[target_table]
        old_ids = records.map { |data| data['record'][pk] }
        migrate_ids[table] = old_ids.index_with do |old_id|
          migrate_ids[target_table].fetch(old_id)
        end.with_indifferent_access
      elsif klass.type_for_attribute(pk).type == :uuid
        old_ids = records.map { |data| data['record'][pk] }
        migrate_ids[table] = old_ids.index_with { SecureRandom.uuid }.with_indifferent_access
      else
        old_ids = records.map { |data| data['record'][pk] }
        migrate_ids[table] = old_ids.zip(reserve_ids(klass, old_ids.length)).to_h.with_indifferent_access
      end
    end
  end

  # Translate a record's foreign-key columns from old ids to new ids in place,
  # using the complete migrate_ids mapping. Polymorphic columns resolve their
  # target table from the record's stored "<column>_type".
  def self.translate_foreign_keys!(attrs, table, migrate_ids)
    (FORWARD_REFERENCES[table] || {}).each_pair do |column, target_table|
      if POLYMORPHIC_COLUMNS.include?(column)
        type = attrs["#{column}_type"]
        old_id = attrs["#{column}_id"]
        next if type.blank? || old_id.blank?
        map = migrate_ids[type.tableize]
        attrs["#{column}_id"] = map[old_id] if map&.has_key?(old_id)
      else
        old_id = attrs[column]
        next if old_id.blank?
        map = migrate_ids[target_table]
        attrs[column] = map[old_id] if map&.has_key?(old_id)
      end
    end
  end

  # Translate snapshotted user/group audiences so mention history and any
  # recovery resolution refer only to imported records.
  def self.translate_notification_payload!(attrs, migrate_ids)
    attrs['recipient_user_ids'] = translate_ids(attrs['recipient_user_ids'], migrate_ids['users'])

    audience_values = attrs['audience_values'] || {}
    %w[
      already_notified_user_ids
      mentioned_group_user_ids
      mentioned_user_ids
      newly_mentioned_user_ids
    ].each do |key|
      audience_values[key] = translate_ids(audience_values[key], migrate_ids['users']) if audience_values.key?(key)
    end
    if audience_values.key?('group_ids')
      audience_values['group_ids'] = translate_ids(audience_values['group_ids'], migrate_ids['groups'])
    end
    attrs['audience_values'] = audience_values
  end

  def self.translate_ids(ids, id_map)
    Array(ids).filter_map do |id|
      id_map&.has_key?(id) ? id_map[id] : id
    end.map(&:to_i).uniq
  end

  def self.prepare_record_for_import!(record, table, original_attrs, klass, reset_keys)
    if reset_keys && original_attrs.has_key?('key')
      record.key = nil
      record.set_key
    end

    ['secret_token', 'token'].each do |name|
      record.send("#{name}=", klass.generate_unique_secure_token) if original_attrs.has_key? name
    end

    if table == 'groups'
      record.handle = GroupService.suggest_handle(name: record.handle, parent_handle: nil)
    end
  end

  def self.download_attachment(record_data, new_id)
    model = record_data['record_type'].classify.constantize.find(new_id)
    URI.open(record_data['url']) do |file|
      blob = ActiveStorage::Blob.create_and_upload!(io: file,
                                                    filename: record_data['filename'],
                                                    content_type: record_data['content_type'])
      model.send(record_data['name']).attach(blob)
      if model.respond_to?(:attachments)
        model.update_attribute(:attachments, model.build_attachments)
      end
    end
  end
end
