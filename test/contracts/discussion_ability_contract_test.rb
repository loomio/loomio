require "test_helper"
require_relative "ability_contract_helper"

# Server answers for starting, editing and announcing threads, checked against
# the client's DiscussionAbility by
# vue/tests/component/discussion_ability_contract.test.js.
class DiscussionAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  GROUP_FIELDS = %i[members_can_edit_discussions members_can_announce
                    members_can_start_discussions non_members_can_start_discussions].freeze
  GROUP_SETTINGS = {
    "permissive" => {members_can_edit_discussions: true, members_can_announce: true,
                     members_can_start_discussions: true, non_members_can_start_discussions: true},
    "restrictive" => {members_can_edit_discussions: false, members_can_announce: false,
                      members_can_start_discussions: false, non_members_can_start_discussions: false}
  }.freeze

  test "writes the discussion ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        settings = topics(topic_name).group_id ? GROUP_SETTINGS : {"defaults" => {}}
        privacies = topics(topic_name).group_id ? %w[closed secret] : [nil]
        settings.keys.product(privacies, [false, true], [false, true]).flat_map do |setting, privacy, locked, discarded|
          cases_for(topic_name, setting, settings.fetch(setting), privacy, locked, discarded)
        end
      end
    end
    write_ability_contract("discussion_abilities", cases)
  end

  private

  def cases_for(topic_name, setting, group_settings, privacy, locked, discarded)
    topic = Topic.find(topics(topic_name).id)
    if topic.group_id
      topic.group.update_columns(group_settings)
      topic.group.group_privacy = privacy
      topic.group.save!(validate: false)
    end
    topic.update_columns(locked_at: (locked ? 1.day.ago : nil))
    discussion = topic.topicable
    original_author_id = discussion.author_id
    discussion.update_columns(discarded_at: (discarded ? 1.hour.ago : nil))

    ROLES.product(%w[other own]).map do |role, authorship|
      user = users(role)
      discussion.update_columns(author_id: authorship == "own" ? user.id : original_author_id)
      discussion.reload
      topic.reload
      expected = answers(user, discussion, %i[update announce])
      if topic.group_id
        new_thread = DiscussionService.build(params: {group_id: topic.group_id, title: "New"}, actor: user)
        expected[:create] = Ability::Base.new(user).can?(:create, new_thread)
      end
      {
        name: "#{role} #{topic_name} #{setting} #{privacy}#{' locked' if locked}#{' discarded' if discarded} #{authorship} thread",
        roles: role_facts(user, topic).merge(author: discussion.author_id == user.id),
        topic: raw(topic, %i[locked_at]),
        group: topic.group_id ? raw(topic.group, GROUP_FIELDS).merge("group_privacy" => topic.group.group_privacy) : {},
        discussion: raw(discussion, %i[discarded_at]).merge("id" => discussion.id, "group_id" => topic.group_id, "topic_id" => topic.id),
        expected: expected
      }
    end.tap { discussion.update_columns(author_id: original_author_id) }
  end
end
