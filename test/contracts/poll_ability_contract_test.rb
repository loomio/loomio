require "test_helper"

# The client interprets raw poll state itself to decide which poll actions to
# offer. This test records the server's Ability answers for a matrix of poll
# states, results settings, thread locks and roles, together with the poll
# fields the client receives from PollSerializer, in tmp/contracts.
# vue/tests/component/poll_ability_contract.test.js checks AbilityService
# against the same cases. The file is generated, so it is not committed.
class PollAbilityContractTest < ActiveSupport::TestCase
  CONTRACT_PATH = Rails.root.join("tmp/contracts/poll_abilities.json")
  CONTRACT_TIME = Time.utc(2026, 1, 1, 12)
  POLL_FIELDS = %w[closed_at closing_at opened_at opening_at discarded_at hide_results anonymous].freeze
  STATES = %w[scheduled open lapsed closed discarded].freeze
  RESULTS = {
    "off" => {hide_results: "off"},
    "until_vote" => {hide_results: "until_vote"},
    "until_closed" => {hide_results: "until_closed"},
    "anonymous" => {hide_results: "until_closed", anonymous: true}
  }.freeze
  # Visitors see the polls in public threads without being members.
  ROLES = {"admin" => :admin, "member" => :user, "visitor" => :alien}.freeze

  test "writes the poll ability contract for the client" do
    contract = JSON.parse(travel_to(CONTRACT_TIME) { build_contract }.to_json)
    CONTRACT_PATH.dirname.mkpath
    CONTRACT_PATH.write(JSON.pretty_generate(contract) + "\n")

    cases = contract.fetch("cases")
    assert_equal STATES.size * RESULTS.size * 2 * ROLES.size, cases.size
    assert_equal cases.size, cases.map { |c| c.fetch("name") }.uniq.size
  end

  private

  def build_contract
    group = groups(:group)
    group.update_columns(is_visible_to_public: true, discussion_privacy_options: "public_or_private")
    cases = STATES.product(RESULTS.keys, [false, true]).flat_map do |state, results, locked|
      poll = build_poll(group, state, RESULTS.fetch(results), locked)
      ROLES.map do |role, fixture|
        user = users(fixture)
        {
          name: "#{role} #{state} #{results}#{' locked' if locked}",
          role: role,
          poll: PollSerializer.new(poll, scope: {current_user_id: user.id}).as_json.fetch(:poll).stringify_keys.slice(*POLL_FIELDS),
          topic: {locked_at: poll.topic.locked_at},
          group: {members_can_edit_discussions: group.members_can_edit_discussions},
          expected: expected_abilities(user, poll)
        }
      end
    end
    {contract_time: CONTRACT_TIME, cases: cases}
  end

  def build_poll(group, state, settings, locked)
    poll = PollService.create(params: {
      poll_type: "proposal", title: "Contract poll", poll_option_names: %w[Agree Disagree],
      group_id: group.id, closing_at: 3.days.from_now,
      opening_at: (1.hour.from_now if state == "scheduled"), **settings
    }, actor: users(:admin))

    case state
    when "lapsed" then poll.update_columns(closing_at: 1.hour.ago)
    when "closed" then PollService.close(poll: poll, actor: users(:admin))
    when "discarded" then PollService.discard(poll: poll, actor: users(:admin))
    end
    poll.topic.update_columns(private: false)
    poll.topic.update_columns(locked_at: 1.day.ago) if locked
    poll.reload
  end

  def expected_abilities(user, poll)
    ability = Ability::Base.new(user)
    {
      update: ability.can?(:update, poll),
      destroy: ability.can?(:destroy, poll),
      close: ability.can?(:close, poll),
      reopen: ability.can?(:reopen, poll),
      export: ability.can?(:export, poll),
      create_outcome: ability.can?(:create, Outcome.new(poll: poll))
    }
  end
end
