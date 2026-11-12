require "test_helper"
require_relative "ability_contract_helper"

# Server answers for ticking a task in a thread's text, checked against the
# client's TaskAbility by vue/tests/component/task_ability_contract.test.js.
# Each case records the task's stored author and mentions and whether the
# viewer can edit the record, which the record's own contracts check.
class TaskAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  test "writes the task ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        topic = Topic.find(topics(topic_name).id)
        comment = Comment.new(parent: topic.topicable, body: "<p>Tasks</p>")
        CommentService.create(comment: comment, actor: topic.admins.order(:id).first!)
        states = topic.group_id ? %w[active on_hold] : %w[active]
        %w[discussion comment].product(states, [false, true]).flat_map do |kind, state, locked|
          record = kind == "discussion" ? topic.topicable : comment
          Subscription.for!(topic.group).update_columns(state: state) if topic.group_id
          topic.update_columns(locked_at: (locked ? 1.day.ago : nil))
          cases_for(topic_name, kind, record, state, locked)
        end
      end
    end
    write_ability_contract("task_abilities", cases)
  end

  private

  def cases_for(topic_name, kind, record, state, locked)
    ROLES.product([false, true], [false, true]).filter_map do |role, authored, mentioned|
      user = users(role)
      next unless user.can?(:show, record.reload)

      task = task_in(record, author: authored ? user : record.author, mentioned: mentioned ? user : nil)
      {
        name: "#{role} #{topic_name} #{kind} #{state}#{' locked' if locked}" \
              "#{' authored' if authored}#{' mentioned' if mentioned} task",
        roles: role_facts(user, record.topic),
        kind: kind,
        group_enabled: record.group.nil? || record.group.enabled?,
        record_update: user.can?(:update, record),
        task: {author_id: task.author_id, mentioned: task.users.exists?(user.id)},
        expected: {update: user.can?(:update, task)}
      }
    end
  end

  def task_in(record, author:, mentioned:)
    field = record.is_a?(Discussion) ? :description : :body
    mention = mentioned ? "<span data-mention-id='#{mentioned.username}'>@#{mentioned.name}</span>" : ""
    record.update_columns(field => "<ul data-type='taskList'><li data-uid='1' data-checked='false' " \
                                   "data-author-id='#{author.id}' data-type='taskItem'><p>Task #{mention}</p></li></ul>")
    record.tasks.destroy_all
    TaskService.parse_and_update(record.reload, field)
    record.tasks.find_by!(uid: 1)
  end
end
