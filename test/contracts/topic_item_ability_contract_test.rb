require "test_helper"
require_relative "ability_contract_helper"

# Server answers for pinning and tagging timeline items, checked against the
# client's TopicItemAbility by vue/tests/component/topic_item_ability_contract.test.js.
class TopicItemAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  ACTIONS = %i[pin unpin update_tags].freeze
  ITEMS = %w[thread own_comment other_comment pinned_comment discarded_comment].freeze

  test "writes the topic item ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        edits = topics(topic_name).group_id ? [true, false] : [nil]
        edits.product([false, true]).flat_map { |members_can_edit, locked| cases_for(topic_name, members_can_edit, locked) }
      end
    end
    write_ability_contract("topic_item_abilities", cases)
  end

  private

  def cases_for(topic_name, members_can_edit, locked)
    topic = Topic.find(topics(topic_name).id)
    topic.update_columns(locked_at: nil)
    topic.group.update_columns(members_can_edit_discussions: members_can_edit) if topic.group_id
    coordinator = topic.admins.order(:id).first!

    ROLES.flat_map do |role|
      user = users(role)
      items = ITEMS.to_h { |kind| [kind, build_item(topic, kind, user, coordinator)] }
      topic.update_columns(locked_at: (locked ? 1.day.ago : nil))
      topic.reload
      items.map do |kind, item|
        item.reload
        model = item.itemable
        {
          name: "#{role} #{topic_name}#{" members-edit-#{members_can_edit}" unless members_can_edit.nil?}#{' locked' if locked} #{kind}",
          roles: role_facts(user, topic),
          topic: raw(topic, %i[locked_at discarded_at]),
          group: topic.group_id ? {members_can_edit_discussions: members_can_edit} : {},
          item: raw(item, %i[kind depth pinned]),
          model: {discarded_at: model.discarded_at, author_id: model.author_id},
          expected: answers(user, item, ACTIONS)
        }
      end.tap { topic.update_columns(locked_at: nil) }
    end
  end

  def build_item(topic, kind, user, coordinator)
    return topic.topicable.created_topic_item if kind == "thread"

    comment = Comment.new(parent: topic.topicable, body: "A comment")
    CommentService.create(comment: comment, actor: coordinator)
    comment.update_columns(user_id: user.id) if kind == "own_comment"
    comment.update_columns(discarded_at: 1.hour.ago, discarded_by: coordinator.id) if kind == "discarded_comment"
    item = comment.created_topic_item
    item.update_columns(pinned: true) if kind == "pinned_comment"
    item
  end
end
