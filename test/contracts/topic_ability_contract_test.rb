require "test_helper"
require_relative "ability_contract_helper"

# Server answers for announcing, inviting guests, moving and tagging threads,
# checked against the client's TopicAbility by
# vue/tests/component/topic_ability_contract.test.js.
class TopicAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  ACTIONS = %i[announce add_guests move move_comments update_tags].freeze
  GROUP_SETTINGS = {
    "permissive" => {members_can_announce: true, members_can_add_guests: true, members_can_edit_discussions: true},
    "restrictive" => {members_can_announce: false, members_can_add_guests: false, members_can_edit_discussions: false}
  }.freeze

  test "writes the topic ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        grouped = topics(topic_name).group_id
        settings = grouped ? GROUP_SETTINGS : {"defaults" => {}}
        settings.keys.product(grouped ? [true, false] : [nil], [false, true], [false, true]).flat_map do |setting, guests, locked, discarded|
          cases_for(topic_name, setting, settings.fetch(setting), guests, locked, discarded)
        end
      end
    end
    write_ability_contract("topic_abilities", cases)
  end

  private

  def cases_for(topic_name, setting, group_settings, guests, locked, discarded)
    topic = Topic.find(topics(topic_name).id)
    if topic.group_id
      topic.group.update_columns(group_settings)
      Subscription.for(topic.group).update_columns(allow_guests: guests)
    end
    topic.update_columns(locked_at: (locked ? 1.day.ago : nil), discarded_at: (discarded ? 1.hour.ago : nil))
    discussion = topic.topicable
    original_author_id = discussion.author_id

    ROLES.product(%w[other own]).map do |role, authorship|
      user = users(role)
      discussion.update_columns(author_id: authorship == "own" ? user.id : original_author_id)
      topic.reload
      {
        name: "#{role} #{topic_name} #{setting}#{" guests-#{guests}" unless guests.nil?}" \
              "#{' locked' if locked}#{' discarded' if discarded} #{authorship} thread",
        roles: role_facts(user, topic),
        topic: raw(topic, %i[locked_at discarded_at group_id]),
        topicable: {author_id: discussion.author_id},
        group: topic.group_id ? raw(topic.group, group_settings.keys).merge(allow_guests: guests) : {},
        expected: answers(user, topic, ACTIONS)
      }
    end.tap { discussion.update_columns(author_id: original_author_id) }
  end
end
