require 'test_helper'

class ReactionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
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
    @comment
    @group.memberships.find_by(user: @reaction.user).destroy

    ReactionService.update(reaction: @reaction, params: { reaction: 'smiley' }, actor: @another_user)

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

    assert_raises CanCan::AccessDenied do
      ReactionService.destroy(reaction: @reaction, actor: @another_user)
    end
  end
end
