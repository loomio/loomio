require 'test_helper'

class RegistrationServiceTest < ActiveSupport::TestCase
  test "returns send_code for a new unproved registration" do
    result = RegistrationService.create(email: "new-registration@example.com", email_control_proved: false)

    assert_equal :send_code, result.status
    assert_predicate result.user, :persisted?
  end

  test "returns send_code for an existing verified account without disclosing it" do
    user = User.create!(email: "verified-registration@example.com", name: "Verified", email_verified: true)

    result = RegistrationService.create(email: user.email, email_control_proved: false)

    assert_equal :send_code, result.status
    assert_equal user, result.user
  end

  test "returns send_code without a user for a deactivated verified account" do
    User.create!(email: "deactivated-registration@example.com", name: "Deactivated", email_verified: true, deactivated_at: Time.current)

    result = RegistrationService.create(email: "deactivated-registration@example.com", email_control_proved: false)

    assert_equal :send_code, result.status
    assert_nil result.user
  end

  test "returns incomplete for a proved provisional account" do
    user = User.create!(email: "incomplete-registration@example.com", email_verified: false)

    result = RegistrationService.create(email: user.email, email_control_proved: true)

    assert_equal :incomplete, result.status
    assert_equal user, result.user
  end

  test "returns sign_in for a proved complete account" do
    user = User.create!(email: "complete-registration@example.com", name: "Complete", email_verified: false, legal_accepted_at: Time.current)

    result = RegistrationService.create(email: user.email, email_control_proved: true)

    assert_equal :sign_in, result.status
    assert_equal user, result.user
  end

  test "returns invalid with model errors" do
    result = RegistrationService.create(email: "invalid", email_control_proved: false)

    assert_equal :invalid, result.status
    assert_predicate result.user.errors[:email], :present?
  end
end
