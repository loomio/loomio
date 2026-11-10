require "test_helper"
require_relative "ability_contract_helper"

# Server answers for reacting in a thread, checked against the client's
# ReactionAbility by vue/tests/component/reaction_ability_contract.test.js.
class ReactionAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  test "writes the reaction ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      (TOPICS + %i[public_discussion_topic]).product([false, true], [true, false]).flat_map do |topic_name, locked, allow|
        topic = Topic.find(topics(topic_name).id)
        topic.update_columns(locked_at: (locked ? 1.day.ago : nil), allow_reactions: allow)
        ROLES.map do |role|
          user = users(role)
          reaction = Reaction.new(reactable: topic.topicable, user: user, reaction: ":heart:")
          {
            name: "#{role} #{topic_name}#{' locked' if locked}#{' no-reactions' unless allow}",
            roles: role_facts(user, topic),
            topic: raw(topic, %i[locked_at allow_reactions]),
            expected: {create: Ability::Base.new(user).can?(:update, reaction)}
          }
        end
      end
    end
    write_ability_contract("reaction_abilities", cases)
  end
end
