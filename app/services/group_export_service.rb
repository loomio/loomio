class GroupExportService
  RELATIONS = %w[
    all_users
    all_events
    all_notifications
    all_reactions
    all_taggings
    memberships
    membership_requests
    discussions
    tags
    exportable_polls
    exportable_poll_options
    exportable_outcomes
    exportable_stances
    exportable_stance_choices
    discussion_readers
    comments
  ]

  JSON_PARAMS = {
    groups:      {except: [:token, :secret_token], methods: []},
    comments:    {except: [:secret_token]},
    discussions: {except: [:secret_token]},
    polls:       {except: [:secret_token]},
    outcomes:    {except: [:secret_token]},
    users:       {except: [:encrypted_password,
                           :reset_password_token,
                           :email_api_key,
                           :reset_password_token, 
                           :secret_token,
                           :unsubscribe_token] }
  }.with_indifferent_access.freeze

  BACK_REFERENCES = {
    comments: {
      comments: %w[parent_id],
      events: %w[eventable]
    },
    discussions: {
      comments: %w[discussion_id],
      discussion_readers: %w[discussion_id],
      polls: %w[discussion_id],
      events: %w[discussion_id eventable]
    },
    events: {
      events: %w[parent_id],
      notifications: %w[event_id]
    },
    groups: {
      memberships: %w[group_id],
      polls: %w[group_id],
      discussions: %w[group_id],
      tags: %w[group_id],
      webhooks: %w[group_id],
      events: %w[eventable]
    },
    poll_options: {
      stance_choices: %w[poll_option_id],
      events: %w[eventable]
    },
    stances: {
      stance_choices: %w[stance_id],
      events: %w[eventable]
    },
    tasks: {
      tasks_users: %w[task_id],
      events: %w[eventable]
    },
    polls: {
      stances: %w[poll_id],
      poll_options: %w[poll_id],
      outcomes: %w[poll_id],
      events: %w[eventable]
    },
    users: {
      events: %w[eventable],
      discussions: %w[author_id discarded_by],
      attachments: %w[user_id],
      comments: %w[user_id discarded_by] ,
      discussion_readers: %w[user_id inviter_id],
      discussions: %w[author_id],
      events: %w[user_id],
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
      templates: %w[author_id],
      versions: %w[whodunnit],
      webhooks: %w[author_id]
    }
  }.with_indifferent_access.freeze

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

        (user_attachments + own_attachments + group.related_attachments).
        compact.flatten.uniq.each do |attachment|
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
      end
    end
    filename
  end

  def self.export_filename_for(group_name)
    "/tmp/#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}_#{group_name.parameterize}.json"
  end

  def self.puts_record(record, file, ids)
    table = record.class.table_name
    return if ids[table].include?(record.id)
    ids[table] << record.id
    file.puts({table: table, record: record.as_json(JSON_PARAMS[table])}.to_json)
  end

  def self.import(filename, reset_keys: false)
    group_ids = []
    migrate_ids = {}
    datas = URI.open(filename, 'r').map { |line| JSON.parse(line) }
    tables = datas.map{ |data| data['table'] }.uniq

    ActiveRecord::Base.transaction do
      #import the records, remember old with new ids
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

          if data['record'].has_key?('secret_token')
            record.secret_token = nil 
          end

          if data['record'].has_key?('token')
            record.token = klass.generate_unique_secure_token
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

      # # changes to REDIS_CONNECTION_POOL
      # SIDEKIQ_REDIS_POOL.with_client do |client|
      #   client.set "import_records_id_map_#{filename}", migrate_ids.to_json
      #   puts "saved id map: redis.get import_records_id_map_#{filename}"
      # end

      # rewrite references to old ids
      tables.each do |table|
        migrate_ids[table].each_pair do |old_id, new_id|
          next unless BACK_REFERENCES.has_key?(table)
          BACK_REFERENCES[table].each_pair do |ref_table, columns|
            next unless migrate_ids[ref_table].present?
            imported_ids = migrate_ids[ref_table].values
            columns.each do |column|
              if column == "eventable"
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
        File.open(filename, 'r').map do |line|
          data = JSON.parse(line)
          next unless (data['table'] == 'attachments')
          table = data['record']['record_type'].tableize
          DownloadAttachmentWorker.perform_async(
            host: origin_host,
            record_type: data['record']['record_type'],
            record_id: migrate_ids[table][data['record']['record_id']],
            old_record_id: data['record']['record_id'],
            filename: data['record']['filename'],
            content_type: data['record']['content_type'],
            url: data['record']['url']
          )
        end
      end
    end

    # SearchIndexWorker.new.perform(Discussion.where(group_id: group_ids).pluck(:id))
  end

  def self.download_attachment(host: ,
                               record_type: ,
                               record_id: ,
                               old_record_id: ,
                               filename: ,
                               content_type: ,
                               url: )
    URI.open(url) do |file|
      # record_type.constantize.find(record_id).files.attach file
    end
  end
end
