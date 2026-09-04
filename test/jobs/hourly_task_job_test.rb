require "test_helper"

class HourlyTaskJobTest < ActiveSupport::TestCase
  test "deletes expired login tokens and retains valid login tokens" do
    valid_token = LoginToken.create!(
      user: users(:user),
      created_at: LoginToken::EXPIRATION.minutes.ago + 1.minute
    )
    expired_token = LoginToken.create!(
      user: users(:user),
      created_at: LoginToken::EXPIRATION.minutes.ago - 1.minute
    )

    HourlyTaskJob.perform_now

    assert LoginToken.exists?(valid_token.id)
    assert_not LoginToken.exists?(expired_token.id)
  end

  test "enqueues inactive user cleanup during midnight maintenance" do
    travel_to Time.new(2026, 9, 5, 0, 0, 0, "+12:00") do
      assert_enqueued_with(job: CleanupInactiveUsersWorker) do
        HourlyTaskJob.perform_now
      end
    end
  end
end
