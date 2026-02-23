require 'test_helper'

class Events::GroupMentionedTest < ActiveSupport::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @group = Group.create!(name: "GM Group #{hex}", handle: "gmgroup#{hex}", group_privacy: 'secret',
                           members_can_announce: true)
    @actor = User.create!(name: "GM Actor #{SecureRandom.hex(4)}", email: "gmactor_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @volume_quiet_member = User.create!(name: "Quiet #{SecureRandom.hex(4)}", email: "gmquiet_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @volume_normal_member = User.create!(name: "Normal #{SecureRandom.hex(4)}", email: "gmnorm_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @volume_loud_member = User.create!(name: "Loud #{SecureRandom.hex(4)}", email: "gmloud_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @mentioned_member = User.create!(name: "Mentioned #{SecureRandom.hex(4)}", email: "gmment_#{SecureRandom.hex(4)}@test.com",
                                     email_verified: true, username: "testuser#{SecureRandom.hex(3)}")

    [@actor, @volume_quiet_member, @volume_normal_member, @volume_loud_member, @mentioned_member].each do |user|
      @group.add_member!(user)
    end
    @group.add_admin!(@actor)

    @group.membership_for(@volume_quiet_member).update!(volume: :quiet)
    @group.membership_for(@volume_normal_member).update!(volume: :normal)
    @group.membership_for(@volume_loud_member).update!(volume: :loud)

    @discussion = DiscussionService.create(params: { group_id: @group.id, title: "GM Test #{SecureRandom.hex(4)}" }, actor: @actor)
    ActionMailer::Base.deliveries.clear
  end

  test "does not notify people more than it should" do
    comment = Comment.new(parent: @discussion, author: @actor,
                          body: "hello @#{@group.handle}, how's it going? special mention @#{@mentioned_member.username}",
                          body_format: 'md')
    Events::NewComment.publish!(comment)
    assert_equal 0, emails_sent_to(@volume_quiet_member.email).size
    assert_equal 1, emails_sent_to(@volume_normal_member.email).size
    assert_equal 1, emails_sent_to(@volume_loud_member.email).size
    assert_equal 1, emails_sent_to(@mentioned_member.email).size
  end

  test "notifies normally" do
    comment = Comment.new(parent: @discussion, author: @actor,
                          body: "hello @#{@group.handle}", body_format: 'md')
    assert_difference -> { Event.where(kind: 'group_mentioned').count }, 1 do
      Events::NewComment.publish!(comment)
    end
  end

  test "does not notify if members cannot announce" do
    @group.update!(members_can_announce: false)
    non_admin = User.create!(name: "NonAdmin #{SecureRandom.hex(4)}", email: "gmnonadmin_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @group.add_member!(non_admin)
    comment = Comment.new(parent: @discussion, author: non_admin,
                          body: "hello @#{@group.handle}", body_format: 'md')
    assert_no_difference -> { Event.where(kind: 'group_mentioned').count } do
      Events::NewComment.publish!(comment)
    end
  end

  test "notifies if members cannot announce but user is admin" do
    @group.update!(members_can_announce: false)
    comment = Comment.new(parent: @discussion, author: @actor,
                          body: "hello @#{@group.handle}", body_format: 'md')
    assert_difference -> { Event.where(kind: 'group_mentioned').count }, 1 do
      Events::NewComment.publish!(comment)
    end
  end

  test "notifies group on edit with newly mentioned group" do
    comment = Comment.new(parent: @discussion, author: @actor,
                          body: "no mentions in here", body_format: 'md')
    Events::NewComment.publish!(comment)
    assert_equal 0, Event.where(kind: 'group_mentioned').count

    comment.update!(body: "edited to mention group @#{@group.handle}")
    Events::CommentEdited.publish!(comment, comment.author)
    assert_equal 1, Event.where(kind: 'group_mentioned').count
  end

  test "does not notify group on edit with existing mention" do
    comment = Comment.new(parent: @discussion, author: @actor,
                          body: "hello @#{@group.handle}", body_format: 'md')
    Events::NewComment.publish!(comment)
    assert_equal 1, Event.where(kind: 'group_mentioned').count

    comment.update!(body: "edited but @#{@group.handle} was already mentioned")
    Events::CommentEdited.publish!(comment, comment.author)
    assert_equal 1, Event.where(kind: 'group_mentioned').count
  end
end
