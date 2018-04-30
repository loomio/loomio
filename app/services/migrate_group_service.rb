class MigrateGroupService
  RELATIONS = %w[
    all_groups
    all_users
    all_events
    all_notifications
    all_documents
    all_reactions
    memberships
    membership_requests
    invitations
    discussions
    polls
    poll_options
    poll_did_not_votes
    poll_unsubscriptions
    outcomes
    stances
    stance_choices
    discussion_readers
    comments
    creator
  ]

  def self.import_from_file(filename, options = {})
    import JSON.parse(File.read(filename), options)
  end

  def self.import(json, options = {})
    json.each do |table_name, records|
      klass = table_name.classify.constantize
      klass.import(records.values.map { |r| klass.new(r) }, {
        validate:                false,
        raise_error:             false,
        on_duplicate_key_update: []
      }.merge(options))
    end
  end

  def self.export_to_file(record)
    File.write(
      "#{record.class.table_name}_#{record.id}_#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}.json",
      export(record).to_json
    )
  end

  def self.export(record, store = Hash.new { |hash, key| hash[key] = {} })
    if record.is_a?(Group)
      store = RELATIONS.reduce(store) { |s, relation| batch_export(record.send(relation), store) }
      store[record.class.table_name][record.id] ||= record.as_json(methods: [:type])
    else
      store[record.class.table_name][record.id] ||= record.as_json
    end

    store
  end

  def self.batch_export(records, store = Hash.new { |hash, key| hash[key] = {} })
    Array(records).compact.reduce(store) { |s, record| export(record, s) }
  end
end
