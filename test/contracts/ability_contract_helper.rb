# Shared setup for client ability contracts. Each contract records the server's
# Ability answers for a matrix of records and users, together with the raw
# fields and role facts the client sees, in tmp/contracts/<name>.json. The
# matching Vitest suite in vue/tests/component checks the client ability module
# against the same cases. The files are generated, so they are not committed.
module AbilityContractHelper
  CONTRACT_TIME = Time.utc(2026, 1, 1, 12)
  CONTRACT_DIR = Rails.root.join("tmp/contracts")

  # The shared access-control matrix: group admins and members, thread guests
  # and thread admins, members of another group, and former members.
  ROLES = %i[admin user guest_normal guest_admin_normal alien former_member_loud].freeze
  TOPICS = %i[discussion_topic direct_topic].freeze

  def write_ability_contract(name, cases)
    contract = JSON.parse({contract_time: CONTRACT_TIME, cases: cases}.to_json)
    CONTRACT_DIR.mkpath
    CONTRACT_DIR.join("#{name}.json").write(JSON.pretty_generate(contract) + "\n")

    names = contract.fetch("cases").map { |c| c.fetch("name") }
    assert names.any?, "#{name} has no cases"
    assert_equal names.size, names.uniq.size, "#{name} case names must be unique"
    contract
  end

  # The role facts the client works out from its membership and reader records.
  def role_facts(user, topic)
    group = topic.group
    {
      user_id: user.id,
      signed_in: user.is_logged_in?,
      email_verified: user.email_verified?,
      server_admin: user.is_admin?,
      group_admin: group.present? && group.admins.exists?(user.id),
      group_member: group.present? && group.members.exists?(user.id),
      parent_admin: group.present? && group.parent_or_self.admins.exists?(user.id),
      topic_admin: topic.admins_include?(user),
      topic_member: topic.members_include?(user)
    }
  end

  def raw(record, fields)
    record.attributes.slice(*fields.map(&:to_s))
  end

  def answers(user, subject, actions)
    ability = Ability::Base.new(user)
    actions.to_h { |action| [action, ability.can?(action, subject)] }
  end
end
