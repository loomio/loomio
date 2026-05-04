require 'test_helper'

class OutcomeServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)

    @poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      poll_option_names: ["Yes", "No"],
      closing_at: 3.days.from_now,
      group_id: @group.id
    }, actor: @user)
    PollService.close(poll: @poll, actor: @user)

    @outcome = Outcome.create(
      poll: @poll,
      author: @user,
      statement: "Test outcome"
    )

    @new_outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "New outcome"
    )

    ActionMailer::Base.deliveries.clear
  end

  test "creates a new outcome" do
    assert_difference 'Outcome.count', 1 do
      OutcomeService.create(outcome: @new_outcome, actor: @user)
    end

    assert_equal @new_outcome.statement, @poll.reload.current_outcome.statement
    assert_equal @new_outcome.author, @poll.current_outcome.author
  end

  test "does not create an invalid outcome" do
    @new_outcome.statement = ""

    assert_difference 'Outcome.count', 0 do
      OutcomeService.create(outcome: @new_outcome, actor: @user)
    end
  end

  test "publishes a due review, and only once" do
    @outcome.update(review_on: Date.today)

    ActionMailer::Base.deliveries.clear
    assert_difference 'Events::OutcomeReviewDue.count', 1 do
      OutcomeService.publish_review_due
    end

    assert_difference 'Events::OutcomeReviewDue.count', 0 do
      OutcomeService.publish_review_due
    end

    last_email = ActionMailer::Base.deliveries.last
    assert_includes last_email.to, @outcome.author.email
  end

  test "does not publish null review_on" do
    @outcome.update(review_on: nil)

    assert_difference 'Events::OutcomeReviewDue.count', 0 do
      OutcomeService.publish_review_due
    end
  end
end
