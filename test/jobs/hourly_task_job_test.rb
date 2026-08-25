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
end
