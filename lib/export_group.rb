# directional, follow from a group down through dependent records
class ExportGroup
  SCHEMA = {
    groups: %w[subgroups membership_requests documents memberships invitations discussions polls creator],
    memberships: %w[events user],
    discussions: %w[author polls comments documents reactions discussion_readers events],
    comments: %w[ author documents events ],
    polls: %w[ author guest_group outcomes stances poll_unsubscriptions poll_options poll_did_not_votes documents events],
    stances: %w[ poll participant events stance_choices reactions ],
    reactions: %w[ user ],
    outcomes: %w[author events reactions],
    events: %w[notifications],
    discussion_readers: %w[user],
    poll_did_not_votes: %w[user]
  }.with_indifferent_access.freeze

  def store
    @store ||= Hash.new { |hash, key| hash[key] = {} }
  end

  def add(record)
    return unless record
    table_name = record.class.table_name
    return if store[table_name].has_key? record.id

    store[table_name][record.id] = record.as_json

    Array(SCHEMA[table_name]).each do |relation|
      Array(record.send(relation)).each { |child| add child } if record.respond_to? relation
    end

  end
end
