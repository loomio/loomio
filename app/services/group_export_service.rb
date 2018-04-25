class GroupExportService
  # directional, follow from a group down through dependent records
  SCHEMA = {
    groups:             %w[subgroups membership_requests documents memberships invitations discussions discussion_readers polls creator],
    memberships:        %w[events user inviter],
    discussions:        %w[author polls comments documents reactions events items],
    comments:           %w[author documents events reactions],
    polls:              %w[author guest_group outcomes stances poll_unsubscriptions poll_options poll_did_not_votes documents events reactions],
    stances:            %w[poll participant events stance_choices reactions],
    reactions:          %w[user],
    outcomes:           %w[author events reactions],
    events:             %w[notifications],
    discussion_readers: %w[user],
    poll_did_not_votes: %w[user]
  }.with_indifferent_access.freeze

  METHODS = { groups: [:type] }.with_indifferent_access.freeze

  # write json
  def self.export(records, name = "loomio_group_export")
    store = Hash.new { |hash, key| hash[key] = {} }
    add(records, store)
    filename = "#{name}_#{DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")}.json"
    File.write filename, store.to_json
    filename
  end

  def self.import(filename)
    JSON.parse(File.read filename).each do |table_name, records|
      klass = table_name.classify.constantize
      klass.import(records.values.map { |record| klass.new record }, validate: false, raise_error: false, on_duplicate_key_update: [])
    end
  end

  private
  def self.add(records, store)
    Array(records).each do |record|
      table_name = record.class.table_name
      return if store[table_name].has_key? record.id

      store[table_name][record.id] = record.as_json(methods: METHODS[table_name])

      Array(SCHEMA[table_name]).each do |relation|
        Array(record.send(relation)).each { |child| add child, store } if record.respond_to? relation
      end
    end
  end
end
