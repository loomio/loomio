require 'test_helper'

class UserServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
  end

  test "deactivates the user" do
    new_user = User.create!(
      name: 'Deactivate Test',
      email: 'deactivate@example.com',
      email_verified: true,
      username: 'deactivatetest'
    )

    UserService.deactivate(user: new_user, actor: new_user)

    assert_not_nil new_user.reload.deactivated_at
  end

  test "deactivation does not change email address" do
    new_user = User.create!(
      name: 'Deactivate Test 2',
      email: 'deactivate2@example.com',
      email_verified: true,
      username: 'deactivatetest2'
    )
    email = new_user.email

    UserService.deactivate(user: new_user, actor: new_user)

    assert_equal email, new_user.reload.email
  end

  test "redacts user and removes personally identifying information" do
    discussion = discussions(:discussion)

    email = @user.email
    user_id = @user.id

    UserService.redact(user: @user, actor: @user)

    @user.reload

    # Verify deactivation
    assert_not_nil @user.deactivated_at

    # Verify PII removed
    assert_nil @user.email
    assert_nil @user[:name]
    assert_nil @user.username
    assert_nil @user.avatar_initials
    assert_nil @user.country
    assert_nil @user.region
    assert_nil @user.city
    assert_nil @user.unlock_token
    assert_nil @user.current_sign_in_ip
    assert_nil @user.last_sign_in_ip
    assert_nil @user.encrypted_password
    assert_nil @user.reset_password_token
    assert_nil @user.reset_password_sent_at
    assert_nil @user.detected_locale
    assert_nil @user.legal_accepted_at

    # Verify empty strings
    assert_equal '', @user.short_bio
    assert_equal '', @user.location

    # Verify false booleans
    assert_equal false, @user.email_newsletter
    assert_equal false, @user.email_verified

    # Verify email_sha256 is set
    assert_equal Digest::SHA256.hexdigest(email), @user.email_sha256

    # Verify versions removed
    assert_equal 0, PaperTrail::Version.where(item_type: 'User', item_id: user_id).count
  end

  test "verifies email if unique" do
    new_user = User.create!(
      name: 'Unverified User',
      email: 'unverified-verify@example.com',
      email_verified: false,
      username: 'unverifiedverify'
    )

    verified_user = UserService.verify(user: new_user)

    assert_equal true, verified_user.email_verified
  end

  test "verify returns user if already verified" do
    verified_user = UserService.verify(user: @user)

    assert_equal true, verified_user.email_verified
  end
end
