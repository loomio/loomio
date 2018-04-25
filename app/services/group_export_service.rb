class GroupExportService
  # directional, follow from a group down through dependent records
  SCHEMA = {
    groups: %w[
     creator

     discussions
     discussion_authors
     discussion_readers

     comments
     comment_authors

     invitations

     memberships
     members
     member_inviters
     membership_requests

     polls
     poll_authors
     poll_guest_groups
     poll_options
     poll_did_not_votes
     poll_did_not_voters
     poll_unsubscriptions

     outcomes
     outcome_authors

     stances
     stance_authors
     stance_choices

     subgroups
     ],
    comments:           %w[reactions documents events],
    polls:              %w[reactions documents events],
    discussions:        %w[reactions documents events items],
    stances:            %w[reactions events],
    outcomes:           %w[reactions events],
    memberships:        %w[events],
    reactions:          %w[user],
    events:             %w[notifications]
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
      existing_ids = klass.where(id: records.keys.map(&:to_i)).pluck(:id)
      klass.import(records.values.map{ |record| klass.new(record) unless existing_ids.include?(record['id']) }.compact, validate: false)
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
