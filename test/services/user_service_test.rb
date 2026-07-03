require 'test_helper'

class UserServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @original_disable_edit_user_profile = ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE']
    @original_sso_force_user_attrs = ENV['LOOMIO_SSO_FORCE_USER_ATTRS']
  end

  teardown do
    ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = @original_disable_edit_user_profile
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] = @original_sso_force_user_attrs
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
    api_key = @user.api_key
    unsubscribe_token = @user.unsubscribe_token

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
    assert_nil @user.current_sign_in_ip
    assert_nil @user.last_sign_in_ip
    assert_nil @user.password_digest
    assert_nil @user.detected_locale
    assert_nil @user.legal_accepted_at

    # Verify empty strings
    assert_equal '', @user.short_bio
    assert_equal '', @user.location

    # Verify false booleans
    assert_equal false, @user.email_newsletter
    assert_equal false, @user.email_verified

    # Verify required tokens remain present but are rotated
    assert_not_nil @user.api_key
    assert_not_nil @user.email_api_key
    assert_not_nil @user.secret_token
    assert_not_nil @user.unsubscribe_token
    refute_equal api_key, @user.api_key
    refute_equal unsubscribe_token, @user.unsubscribe_token

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

  test "disable edit user profile blocks externally managed fields but allows local fields" do
    ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'] = '1'
    original_name = @user.name
    original_email = @user.email
    original_username = @user.username
    original_avatar_kind = @user.avatar_kind

    UserService.update(
      user: @user,
      actor: @user,
      params: {
        name: 'Managed Name',
        email: "managed#{SecureRandom.hex(4)}@example.com",
        username: "managed#{SecureRandom.hex(4)}",
        avatar_kind: 'uploaded',
        short_bio: 'Local introduction',
        location: 'Local place'
      }
    )

    @user.reload
    assert_equal original_name, @user.name
    assert_equal original_email, @user.email
    assert_equal original_username, @user.username
    assert_equal original_avatar_kind, @user.avatar_kind
    assert_equal 'Local introduction', @user.short_bio
    assert_equal 'Local place', @user.location
  end
end
