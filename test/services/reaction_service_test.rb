require 'test_helper'

class ReactionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
    @discussion = discussions(:discussion)
    @comment = Comment.create(
      parent: @discussion,
      author: @user,
      body: "test comment"
    )

    @reaction = Reaction.new(
      reaction: ":heart:",
      reactable: @comment,
      user: @user
    )
  end

  test "creates a reaction for the current user on a comment" do
    assert_difference 'Reaction.count', 1 do
      ReactionService.update(reaction: @reaction, params: { reaction: 'smiley' }, actor: @user)
    end
  end

  test "does not notify if the user is no longer in the group" do
    @group.memberships.find_by(user: @user).destroy

    reactor_reaction = Reaction.new(reaction: ":heart:", reactable: @comment, user: @admin)
    ReactionService.update(reaction: reactor_reaction, params: { reaction: 'smiley' }, actor: @admin)

    assert_equal 0, @user.notifications.count
  end

  test "removes a reaction for the current user on a comment" do
    @reaction.save

    assert_difference 'Reaction.count', -1 do
      ReactionService.destroy(reaction: @reaction, actor: @user)
    end
  end

  test "does not allow others to destroy a reaction" do
    @reaction.save

    outsider = User.create!(
      name: 'Outsider',
      email: "outsider#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "outsider#{SecureRandom.hex(4)}"
    )

    assert_raises CanCan::AccessDenied do
      ReactionService.destroy(reaction: @reaction, actor: outsider)
    end
  end
end
