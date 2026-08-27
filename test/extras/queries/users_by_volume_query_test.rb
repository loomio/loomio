require 'test_helper'

class Queries::UsersByVolumeQueryTest < ActiveSupport::TestCase
  setup do
    @group = groups(:group)
    @author = users(:admin)
    @discussion = discussions(:discussion)

    def new_user(name)
      hex = SecureRandom.hex(4)
      User.create!(name: name, email: "#{name.parameterize}#{hex}@example.com", username: "#{name.parameterize.gsub(/[^a-z0-9]/, '')}#{hex}")
    end

    @user_reader_loud = new_user("reader_loud")
    @user_membership_loud = new_user("membership_loud")
    @user_reader_normal = new_user("reader_normal")
    @user_membership_normal = new_user("membership_normal")
    @user_reader_quiet = new_user("reader_quiet")
    @user_membership_quiet = new_user("membership_quiet")
    @user_revoked = new_user("revoked")

    @group.add_member!(@user_membership_loud).set_volume!(email: :loud, push: :mute)
    @group.add_member!(@user_membership_normal).set_volume!(email: :normal, push: :mute)
    @group.add_member!(@user_membership_quiet).set_volume!(email: :quiet, push: :mute)
    @group.add_member!(@user_revoked).set_volume!(email: :normal, push: :mute)
    @group.membership_for(@user_revoked).update!(revoked_at: 1.day.ago)

    @group.add_member!(@user_reader_loud).set_volume!(email: :quiet, push: :mute)
    @group.add_member!(@user_reader_normal).set_volume!(email: :quiet, push: :mute)
    @group.add_member!(@user_reader_quiet).set_volume!(email: :quiet, push: :mute)

    TopicReader.for(user: @user_reader_loud, topic: @discussion.topic).set_volume!(email: :loud, push: :mute)
    TopicReader.for(user: @user_reader_normal, topic: @discussion.topic).set_volume!(email: :normal, push: :mute)
    TopicReader.for(user: @user_reader_quiet, topic: @discussion.topic).set_volume!(email: :quiet, push: :mute)

    ActionMailer::Base.deliveries.clear
  end

  test "loud returns only loud users" do
    users = Queries::UsersByVolumeQuery.loud(@discussion.topic)
    assert_includes users, @user_reader_loud
    assert_includes users, @user_membership_loud
    refute_includes users, @user_membership_normal
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_reader_normal
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_revoked
  end

  test "normal or loud returns normal and loud users" do
    users = Queries::UsersByVolumeQuery.normal_or_loud(@discussion.topic)
    assert_includes users, @user_reader_loud
    assert_includes users, @user_reader_normal
    assert_includes users, @user_membership_loud
    assert_includes users, @user_membership_normal
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_revoked
  end

  test "quiet returns only quiet users" do
    users = Queries::UsersByVolumeQuery.quiet(@discussion.topic)
    assert_includes users, @user_membership_quiet
    assert_includes users, @user_reader_quiet
    refute_includes users, @user_reader_loud
    refute_includes users, @user_membership_loud
    refute_includes users, @user_membership_normal
    refute_includes users, @user_reader_normal
    refute_includes users, @user_revoked
  end

  test "accepts a group" do
    users = Queries::UsersByVolumeQuery.normal_or_loud(@discussion.group)
    assert_includes users, @user_membership_loud
    assert_includes users, @user_membership_normal
    refute_includes users, @user_reader_loud
    refute_includes users, @user_reader_normal
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_revoked
  end

  test "deals with nils" do
    assert_equal User.none, Queries::UsersByVolumeQuery.normal_or_loud(nil)
  end
end
