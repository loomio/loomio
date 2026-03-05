require 'test_helper'

class Queries::UsersByVolumeQueryTest < ActiveSupport::TestCase
  setup do
    @group = groups(:test_group)
    @author = users(:discussion_author)
    @group.add_admin!(@author)
    @discussion = create_discussion(group: @group, author: @author)

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
    @user_reader_mute = new_user("reader_mute")
    @user_membership_mute = new_user("membership_mute")
    @user_revoked = new_user("revoked")

    @group.add_member!(@user_membership_loud).set_email_volume!(:loud)
    @group.add_member!(@user_membership_normal).set_email_volume!(:normal)
    @group.add_member!(@user_membership_quiet).set_email_volume!(:quiet)
    @group.add_member!(@user_membership_mute).set_email_volume!(:mute)
    @group.add_member!(@user_revoked).set_email_volume!(:normal)
    @group.membership_for(@user_revoked).update!(revoked_at: 1.day.ago)

    @group.add_member!(@user_reader_loud).set_email_volume!(:mute)
    @group.add_member!(@user_reader_normal).set_email_volume!(:mute)
    @group.add_member!(@user_reader_quiet).set_email_volume!(:mute)
    @group.add_member!(@user_reader_mute).set_email_volume!(:mute)

    DiscussionReader.for(discussion: @discussion, user: @user_reader_loud).set_email_volume!(:loud)
    DiscussionReader.for(discussion: @discussion, user: @user_reader_normal).set_email_volume!(:normal)
    DiscussionReader.for(discussion: @discussion, user: @user_reader_quiet).set_email_volume!(:quiet)
    DiscussionReader.for(discussion: @discussion, user: @user_reader_mute).set_email_volume!(:mute)

    ActionMailer::Base.deliveries.clear
  end

  test "loud returns only loud users" do
    users = Queries::UsersByVolumeQuery.loud(@discussion)
    assert_includes users, @user_reader_loud
    assert_includes users, @user_membership_loud
    refute_includes users, @user_membership_normal
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_membership_mute
    refute_includes users, @user_reader_normal
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_reader_mute
    refute_includes users, @user_revoked
  end

  test "normal or loud returns normal and loud users" do
    users = Queries::UsersByVolumeQuery.normal_or_loud(@discussion)
    assert_includes users, @user_reader_loud
    assert_includes users, @user_reader_normal
    assert_includes users, @user_membership_loud
    assert_includes users, @user_membership_normal
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_membership_mute
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_reader_mute
    refute_includes users, @user_revoked
  end

  test "mute returns only muted users" do
    users = Queries::UsersByVolumeQuery.mute(@discussion)
    assert_includes users, @user_membership_mute
    assert_includes users, @user_reader_mute
    refute_includes users, @user_reader_loud
    refute_includes users, @user_membership_loud
    refute_includes users, @user_membership_normal
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_reader_normal
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_revoked
  end

  test "accepts a group" do
    users = Queries::UsersByVolumeQuery.normal_or_loud(@discussion.group)
    assert_includes users, @user_membership_loud
    assert_includes users, @user_membership_normal
    refute_includes users, @user_reader_loud
    refute_includes users, @user_reader_normal
    refute_includes users, @user_reader_quiet
    refute_includes users, @user_reader_mute
    refute_includes users, @user_membership_quiet
    refute_includes users, @user_membership_mute
    refute_includes users, @user_revoked
  end

  test "deals with nils" do
    assert_equal User.none, Queries::UsersByVolumeQuery.normal_or_loud(nil)
  end
end
