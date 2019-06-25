class GroupExportService
  RELATIONS = %w[
    all_users
    all_events
    all_notifications
    all_documents
    all_reactions
    memberships
    membership_requests
    discussions
    exportable_polls
    exportable_poll_options
    exportable_poll_did_not_votes
    exportable_poll_unsubscriptions
    exportable_outcomes
    exportable_stances
    exportable_stance_choices
    discussion_readers
    comments
  ]

  JSON_PARAMS = { groups: {methods: [:type]},
                  users:  {except: [:encrypted_password,
                                    :reset_password_token,
                                    :email_api_key,
                                    :reset_password_token,
                                    :unsubscribe_token] }}.with_indifferent_access.freeze

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

  def self.import(filename)
    group_ids = []
    tables = File.open(filename, 'r').map { |line| JSON.parse(line)['table'] }.uniq
    tables.each do |table|
      klass = table.classify.constantize
      # existing_ids = klass.pluck(:id)
      new_records = File.open(filename, 'r').map do |line|
        data = JSON.parse(line)
        next unless (data['table'] == table)
        record = klass.new(data['record'])
        group_ids << record.id if table == "groups"
        record
      end.compact!
      klass.import(new_records, validate: false, on_duplicate_key_ignore: true)

      # SearchVector.index_everything!
    end
    SearchVector.index_without_delay! Discussion.where(group_id: group_ids).pluck(:id)
  end
end
