require "test_helper"
require_relative "ability_contract_helper"

# Server answers for creating, replying to, editing and removing comments,
# checked against the client's CommentAbility by
# vue/tests/component/comment_ability_contract.test.js.
class CommentAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  COMMENT_FIELDS = %i[discarded_at discarded_by].freeze
  TOPIC_FIELDS = %i[locked_at allow_comments].freeze
  GROUP_SETTINGS = {
    "permissive" => {members_can_edit_comments: true, members_can_delete_comments: true, admins_can_edit_user_content: true},
    "restrictive" => {members_can_edit_comments: false, members_can_delete_comments: false, admins_can_edit_user_content: false}
  }.freeze
  COMMENTS = %w[own other own_discarded other_discarded_by_admin own_with_reply].freeze

  test "writes the comment ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.flat_map do |topic_name|
        settings = topics(topic_name).group_id ? GROUP_SETTINGS : {"defaults" => {}}
        settings.keys.product([false, true], [true, false]).flat_map do |setting, locked, allow_comments|
          cases_for(topic_name, setting, settings.fetch(setting), locked, allow_comments)
        end
      end
    end
    write_ability_contract("comment_abilities", cases)
  end

  private

  def cases_for(topic_name, setting, group_settings, locked, allow_comments)
    topic = Topic.find(topics(topic_name).id)
    topic.group.update_columns(group_settings) if topic.group_id
    topic.update_columns(locked_at: (locked ? 1.day.ago : nil), allow_comments: allow_comments)
    coordinator = topic.admins.order(:id).first!

    ROLES.flat_map do |role|
      user = users(role)
      COMMENTS.map do |kind|
        comment = build_comment(topic, kind, user, coordinator)
        topic.reload
        {
          name: "#{role} #{topic_name} #{setting}#{' locked' if locked}#{' no-comments' unless allow_comments} #{kind} comment",
          roles: role_facts(user, topic).merge(author: comment.user_id == user.id),
          topic: raw(topic, TOPIC_FIELDS),
          group: topic.group_id ? raw(topic.group, group_settings.keys) : {},
          comment: raw(comment, COMMENT_FIELDS).merge("id" => comment.id),
          reply_count: Comment.where(parent: comment).count,
          expected: {
            create: Ability::Base.new(user).can?(:create, Comment.new(parent: topic.topicable, user: user)),
            reply: Ability::Base.new(user).can?(:create, Comment.new(parent: comment, user: user))
          }.merge(answers(user, comment, %i[update discard undiscard destroy]))
        }
      end
    end
  end

  def build_comment(topic, kind, user, coordinator)
    author = kind.start_with?("own") ? user : coordinator
    comment = Comment.new(parent: topic.topicable, user: author, body: "A comment")
    comment.save!(validate: false)
    case kind
    when "own_discarded" then comment.update_columns(discarded_at: 1.hour.ago, discarded_by: author.id)
    when "other_discarded_by_admin" then comment.update_columns(discarded_at: 1.hour.ago, discarded_by: coordinator.id)
    when "own_with_reply" then Comment.new(parent: comment, user: coordinator, body: "A reply").save!(validate: false)
    end
    comment
  end
end
