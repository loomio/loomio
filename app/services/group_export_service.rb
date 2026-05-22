class GroupExportService
  RELATIONS = %w[
    all_users
    all_events
    all_notifications
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
    exportable_outcomes
    exportable_stances
    exportable_stance_choices
    poll_stance_receipts
    topic_readers
    comments
  ]

  JSON_PARAMS = {
    groups:      {except: [:token], methods: []},
    users:       {except: [:encrypted_password,
                           :reset_password_token,
                           :email_api_key,
                           :reset_password_token,
                           :secret_token,
                           :unsubscribe_token] }
  }.with_indifferent_access.freeze

  BACK_REFERENCES = {
    outcomes: {
      events: %w[eventable]
    },
    comments: {
      comments: %w[parent_id],
      events: %w[eventable],
      reactions: %w[reactable]
    },
    discussions: {
      topics: %w[topicable],
      comments: %w[parent],
      events: %w[eventable],
      reactions: %w[reactable]
    },
    topics: {
      discussions: %w[topic_id],
      polls: %w[topic_id],
      events: %w[topic_id],
      topic_readers: %w[topic_id]
    },
    events: {
      events: %w[parent_id],
      notifications: %w[event_id]
    },
    groups: {
      memberships: %w[group_id],
      topics: %w[group_id],
      tags: %w[group_id],
      webhooks: %w[group_id],
      events: %w[eventable],
      groups: %w[parent_id],
      poll_templates: %w[group_id],
      discussion_templates: %w[group_id]
    },
    poll_options: {
      stance_choices: %w[poll_option_id],
      events: %w[eventable]
    },
    stances: {
      stance_choices: %w[stance_id],
      events: %w[eventable],
      reactions: %w[reactable]
    },
    tasks: {
      tasks_users: %w[task_id],
      events: %w[eventable]
    },
    polls: {
      topics: %w[topicable],
      stance_receipts: %w[poll_id],
      stances: %w[poll_id],
      poll_options: %w[poll_id],
      outcomes: %w[poll_id],
      events: %w[eventable],
      reactions: %w[reactable]
    },
    users: {
      stance_receipts: %w[voter_id inviter_id],
      events: %w[eventable user_id],
      discussions: %w[author_id discarded_by],
      discussion_templates: %w[author_id],
      poll_templates: %w[author_id],
      attachments: %w[user_id],
      comments: %w[user_id discarded_by] ,
      topic_readers: %w[user_id inviter_id],
      groups: %w[creator_id],
      membership_requests: %w[requestor_id responder_id],
      memberships: %w[user_id inviter_id],
      notifications: %w[user_id],
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

  def self.export_direct_topics(group_id)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids
    author_ids = Membership.where(group_id: group_ids).pluck(:user_id).uniq
    topics = Topic.joins_topicables
                  .where(group_id: nil)
                  .where("discussions.author_id IN (:author_ids) OR polls.author_id IN (:author_ids)", author_ids: author_ids)
    filename = "/tmp/#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}_invite-only-topics-for-#{group.name.parameterize}.json"
    ids = Hash.new { |hash, key| hash[key] = [] }

    File.open(filename, 'w') do |file|
      topics.find_each(batch_size: 20000) do |topic|
        export_direct_topic(topic, file, ids)
      end
    end

    filename
  end

  def self.export_direct_topic(topic, file, ids)
    puts_record(topic, file, ids)
    puts_record(topic.topicable, file, ids) if topic.topicable

    polls = Poll.where(topic_id: topic.id).where("anonymous = false OR closed_at is not null")
    outcomes = Outcome.where(poll_id: polls.select(:id))
    stances = Stance.where(poll_id: polls.select(:id))
    comments = topic.comments

    [
      polls,
      PollOption.where(poll_id: polls.select(:id)),
      outcomes,
      stances,
      StanceChoice.where(stance_id: stances.select(:id)),
      StanceReceipt.where(poll_id: polls.select(:id)),
      topic.items,
      topic.topic_readers,
      comments,
      topic.members
    ].each do |records|
      export_records(records, file, ids)
    end

    export_records(reactions_for_records([topic.topicable].compact + polls.to_a + stances.to_a + outcomes.to_a + comments.to_a), file, ids)

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

  def self.export_records(records, file, ids)
    records.find_each(batch_size: 20000) do |record|
      puts_record(record, file, ids)
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
    File.open(filename, 'w') do |file|
      groups.each do |group|
        puts_record(group, file, ids)
        RELATIONS.each do |relation|
          # puts "Exporting: #{relation}"
          group.send(relation).find_each(batch_size: 20000) do |record|
            puts_record(record, file, ids)
          end
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

  def self.puts_record(record, file, ids)
    table = record.class.table_name
    return if ids[table].include?(record.id)
    ids[table] << record.id
    file.puts({table: table, record: record.as_json(JSON_PARAMS[table])}.to_json)
  end

  def self.import(filename_or_url, reset_keys: false)
    group_ids = []
    migrate_ids = {}

    if URI.parse(filename_or_url).class == URI::Generic
      datas = File.open(filename_or_url).read.split("\n").map { |line| JSON.parse(line) }
    else
      datas = URI.parse(filename_or_url).read.split("\n").map { |line| JSON.parse(line) }
    end

    tables = datas.map{ |data| data['table'] }.uniq

    ActiveRecord::Base.transaction do
      # import the records, remember old with new ids
      (tables - ['attachments']).each do |table|
        migrate_ids[table] = {}
        klass = table.classify.constantize
        datas.each do |data|
          next unless (data['table'] == table)
          record = klass.new(data['record'])

          if reset_keys && data['record'].has_key?('key')
            record.key = nil
            record.set_key
          end

          ['secret_token', 'token'].each do |name|
            record.send("#{name}=", klass.generate_unique_secure_token) if data['record'].has_key? name
          end

          if table == 'groups'
            record.handle = GroupService.suggest_handle(name: record.handle, parent_handle: nil)
          end

          old_id = record.id
          record.id = nil
          result = klass.import([record], validate: false, on_duplicate_key_ignore: true)
          if new_id = result.ids.map(&:to_i).first
            migrate_ids[table][old_id] = new_id
          else
            # duplicate record exists
            if table == 'users'
              migrate_ids[table][old_id] = User.find_by(email: record.email).id
            else
              raise "failed to import #{table} record - conflict on unique column. handle that here"
            end
          end
        end
      end

      # SIDEKIQ_REDIS_POOL.with_client do |client|
      #   client.set "last_migrate_ids", migrate_ids.to_json
      # end

      # rewrite references to old ids
      (tables - ['attachments']).each do |table|
        migrate_ids[table].each_pair do |old_id, new_id|
          next unless BACK_REFERENCES.has_key?(table)
          BACK_REFERENCES[table].each_pair do |ref_table, columns|
            next unless migrate_ids[ref_table].present?
            imported_ids = migrate_ids[ref_table].values
            columns.each do |column|
              if ['eventable', 'reactable', 'topicable', 'parent'].include? column
                ref_table.classify.constantize.
                where(id: imported_ids).
                where(column+"_type" => table.classify, column+"_id" => old_id).
                update_all(column+"_id" => new_id)
              else
                ref_table.classify.constantize.
                where(id: imported_ids).
                where(column => old_id).
                update_all(column => new_id)
              end
            end
          end
        end
      end

      if tables.include?('attachments')
        datas.each do |data|
          next unless (data['table'] == 'attachments')
          table = data['record']['record_type'].tableize
          new_id = migrate_ids[table][data['record']['record_id']]
          DownloadAttachmentWorker.perform_async(data['record'], new_id)
        end
      end

      datas.each do |data|
        if data['table'] == 'polls'
          new_id = migrate_ids['polls'][data['record']['id']]
          Poll.find(new_id).update_counts!
          Poll.find(new_id).stances.each(&:update_option_scores!)
        end
      end
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
