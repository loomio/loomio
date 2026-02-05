require 'test_helper'

class StanceServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_member!(@user) unless @group.members.include?(@user)
    @discussion = create_discussion(group: @group, author: @user)
  end

  test "does not create an invalid stance" do
    # Create a proposal poll
    poll = Poll.new(
      title: 'Proposal',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      discussion: @discussion,
      poll_option_names: ['agree', 'abstain', 'disagree', 'block']
    )
    PollService.create(poll: poll, actor: @user)

    invalid_stance = Stance.new(
      poll: poll
    )
    # No stance_choices - invalid

    assert_raises ActiveRecord::RecordInvalid do
      StanceService.create(stance: invalid_stance, actor: @user)
    end
  end

  test "does not allow an unauthorized member to create a stance" do
    poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['agree', 'disagree'],
      discussion: @discussion
    )
    PollService.create(poll: poll, actor: @user)
    poll.reload
    agree = poll.poll_options.find_by(name: 'Agree')

    unauthorized_user = User.create!(
      name: 'Unauthorized',
      email: 'unauthorizedstance@example.com',
      email_verified: true,
      username: 'unauthorizedstance'
    )
    # Don't add to group

    new_stance = Stance.new(
      poll: poll,
      reason: 'trying to vote'
    )
    new_stance.stance_choices_attributes = [{ poll_option_id: agree.id }]

    assert_raises CanCan::AccessDenied do
      StanceService.create(stance: new_stance, actor: unauthorized_user)
    end
  end
end
