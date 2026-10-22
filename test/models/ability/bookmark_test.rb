require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::BookmarkTest < ActiveSupport::TestCase
  test "bookmark access belongs to its owner across group and direct topic roles" do
    owner = users(:guest_normal)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]

    %i[discussion_topic direct_topic].each do |topic_name|
      bookmark = Bookmark.create!(user: owner, bookmarkable: topics(topic_name).topicable)
      actors.each do |actor|
        %i[show update destroy].each do |action|
          assert_equal actor.id == owner.id, actor.can?(action, bookmark), "#{topic_name}, #{action}, actor=#{actor.id}"
        end
      end
    end
  end

  test "lost topic access prevents restoring a bookmark but permits removing it" do
    owner = users(:guest_normal)

    %i[discussion_topic direct_topic].each do |topic_name|
      topic = topics(topic_name)
      bookmark = Bookmark.create!(user: owner, bookmarkable: topic.topicable, discarded_at: Time.current)
      assert owner.can?(:update, bookmark)
      topic.topic_readers.find_by!(user: owner).update!(revoked_at: Time.current)
      owner.reload

      assert_not owner.can?(:update, bookmark)
      assert owner.can?(:destroy, bookmark)
    end
  end
end
