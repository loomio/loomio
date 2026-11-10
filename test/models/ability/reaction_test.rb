require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::ReactionTest < ActiveSupport::TestCase
  test "only thread members can react, including on public threads" do
    topic = topics(:public_discussion_topic)
    member = users(:user)
    Membership.create!(user: member, group: topic.group, accepted_at: Time.current)
    visitor = users(:alien)
    assert visitor.can?(:show, topic.topicable), "the visitor can see the public thread"

    assert member.can?(:update, Reaction.new(user: member, reactable: topic.topicable, reaction: "👍"))
    assert_not visitor.can?(:update, Reaction.new(user: visitor, reactable: topic.topicable, reaction: "👍"))
  end

  test "locked threads accept no new reactions but authors can still remove theirs" do
    topic = topics(:discussion_topic)
    member = users(:user)
    existing = Reaction.create!(user: member, reactable: topic.topicable, reaction: "👍")
    topic.update_columns(locked_at: 1.day.ago)

    assert_not member.can?(:update, Reaction.new(user: member, reactable: topic.topicable.reload, reaction: "🎉"))
    assert member.can?(:destroy, existing)
  end

  test "reacting needs visibility and thread membership while removal belongs to its author" do
    owner = users(:guest_normal)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]

    %i[discussion_topic direct_topic public_discussion_topic].each do |topic_name|
      topic = topics(topic_name)
      target = topic.topicable
      reaction = Reaction.create!(user: owner, reactable: target, reaction: "👍")

      [false, true].each do |enabled|
        topic.update!(allow_reactions: enabled)
        target.topic = topic
        actors.each do |actor|
          visible = actor.can?(:show, target)
          context = "#{topic_name}, enabled=#{enabled}, actor=#{actor.id}"
          assert_equal visible, actor.can?(:show, reaction), context
          member = actor.is_logged_in? && topic.members_include?(actor)
          assert_equal visible && enabled && member, actor.can?(:update, reaction), context
          assert_equal actor.id == owner.id, actor.can?(:destroy, reaction), context
        end
      end
    end
  end
end
