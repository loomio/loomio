require 'test_helper'
require_relative '../../support/access_volume_matrix'

class Ability::DiscussionAccessTest < ActiveSupport::TestCase
  test "authors and coordinators can manage discussions independently on group and direct topics" do
    topics(:discussion_topic).group.update!(members_can_edit_discussions: false)
    topics(:discussion_topic).group.add_admin!(users(:member_normal))

    %i[discussion_topic direct_topic].each do |name|
      discussion = topics(name).discussion
      discussion.update!(author: users(:guest_normal))
      allowed = %i[guest_normal guest_admin_normal]
      allowed += %i[admin member_normal] if name == :discussion_topic

      AccessVolumeMatrix::ROLES.each do |role|
        %i[update destroy discard].each do |action|
          permitted = allowed.include?(role) || (name == :direct_topic && action == :update && %i[guest_quiet guest_loud].include?(role))
          assert_equal permitted, users(role).can?(action, discussion), "#{name}: #{role} #{action}"
        end
      end
      [users(:server_admin), LoggedOutUser.new].each do |outsider|
        %i[update destroy discard].each { |action| assert_not outsider.can?(action, discussion) }
      end
    end
  end

  test "member editing permits updates without permitting removal" do
    discussion = topics(:discussion_topic).discussion
    discussion.group.update!(members_can_edit_discussions: true)
    member = users(:member_normal)
    assert_not_equal member, discussion.author
    assert_not discussion.admins.exists?(member.id)

    assert member.can?(:update, discussion)
    assert_not member.can?(:destroy, discussion)
    assert_not member.can?(:discard, discussion)
    assert_not users(:alien).can?(:update, discussion)
  end
end
