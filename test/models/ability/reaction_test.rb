require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::ReactionTest < ActiveSupport::TestCase
  test "reaction visibility follows its topic while removal belongs to its author" do
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
          assert_equal actor.is_logged_in? && visible && enabled, actor.can?(:update, reaction), context
          assert_equal actor.id == owner.id, actor.can?(:destroy, reaction), context
        end
      end
    end
  end
end
