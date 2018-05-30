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
    polls
    poll_options
    poll_did_not_votes
    poll_unsubscriptions
    outcomes
    stances
    stance_choices
    discussion_readers
    comments
  ]

  METHODS = { groups: [:type] }.with_indifferent_access.freeze

  def self.export(group)
    ids = Hash.new { |hash, key| hash[key] = [] }
    filename = "tmp/#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}_#{group.name.parameterize}.json"
    File.open(filename, 'w') do |file|
      group.all_groups.each do |group|
        puts_record(group, file, ids)
        RELATIONS.each do |relation|
          group.send(relation).find_each(batch_size: 20000) { |record| puts_record(record, file, ids) }
        end
      end
    end
    filename
  end

  def self.puts_record(record, file, ids)
    table = record.class.table_name
    return if ids[table].include?(record.id)
    ids[table] << record.id
    file.puts({table: table, record: record.as_json(methods: METHODS[table])}.to_json)
  end

  def self.import(filename)
    File.open(filename, 'r').each do |line|
      data = JSON.parse(line)
      data['table'].classify.constantize.new(data['record']).save(validate: false)
    end
  end
end
