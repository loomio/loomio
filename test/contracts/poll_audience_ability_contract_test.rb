require "test_helper"
require_relative "ability_contract_helper"

# Server answers for starting polls and managing who takes part, across the
# shared role matrix, checked against the client's PollAbility by
# vue/tests/component/poll_audience_ability_contract.test.js.
class PollAudienceAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  POLL_FIELDS = %w[group_id topic_id closed_at closing_at opened_at opening_at discarded_at hide_results anonymous specified_voters_only].freeze
  SETTINGS = {
    "permissive" => {members_can_announce: true, members_can_add_guests: true, members_can_raise_motions: true, members_can_edit_discussions: true},
    "restrictive" => {members_can_announce: false, members_can_add_guests: false, members_can_raise_motions: false, members_can_edit_discussions: false}
  }.freeze
  STATES = %w[open closed closed_anonymous].freeze

  test "writes the poll audience ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        settings = topics(topic_name).group_id ? SETTINGS : {"defaults" => {}}
        settings.keys.product(STATES, [false, true], [false, true]).flat_map do |setting, state, specified, locked|
          cases_for(topic_name, setting, settings.fetch(setting), state, specified, locked)
        end
      end
    end
    write_ability_contract("poll_audience_abilities", cases)
  end

  private

  # The client only holds polls it can see, so record viewing answers only then.
  def visible_answers(ability, poll)
    ability.can?(:show, poll) ? {view_anonymous_voters: ability.can?(:view_anonymous_voters, poll)} : {}
  end

  def cases_for(topic_name, setting, group_settings, state, specified, locked)
    topic = Topic.find(topics(topic_name).id)
    topic.update_columns(polls_one_at_a_time: false, locked_at: nil)
    if topic.group_id
      topic.group.update_columns(group_settings)
      Subscription.for!(topic.group).update_columns(allow_guests: true)
    end
    coordinator = topic.admins.order(:id).first!
    anonymous = state == "closed_anonymous"
    poll = PollService.create(params: {
      title: "Audience contract", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 3.days.from_now, topic_id: topic.id, notify_on_open: false, specified_voters_only: specified,
      anonymous: anonymous, hide_results: (anonymous ? "until_closed" : "off")
    }, actor: coordinator)
    PollService.close(poll: poll, actor: coordinator) if state.start_with?("closed")
    topic.update_columns(locked_at: 1.day.ago) if locked
    topic.reload

    ROLES.map do |role|
      user = users(role)
      ability = Ability::Base.new(user)
      serialized = PollSerializer.new(poll.reload, scope: {current_user_id: user.id}).as_json.fetch(:poll).stringify_keys
      {
        name: "#{role} #{topic_name} #{setting} #{state}#{' specified-voters' if specified}#{' locked' if locked} poll",
        roles: role_facts(user, topic).merge(poll_admin: poll.admins.exists?(user.id), poll_member: poll.members.exists?(user.id)),
        poll: serialized.slice(*POLL_FIELDS).merge("group_id" => topic.group_id, "anonymous_ballot_submitted" => false),
        topic: raw(topic, %i[group_id locked_at topicable_type active_polls_count polls_one_at_a_time]),
        group: topic.group_id ? raw(topic.group, group_settings.keys).merge(allow_guests: true) : {},
        expected: {
          create: ability.can?(:create, Poll.new(topic: topic, author: user)),
          announce: ability.can?(:announce, poll),
          remind: ability.can?(:remind, poll),
          add_voters: ability.can?(:add_voters, poll),
          add_guests: ability.can?(:add_guests, poll.topic),
          create_outcome: ability.can?(:create, Outcome.new(poll: poll, author: user))
        }.merge(visible_answers(ability, poll))
      }
    end
  end
end
