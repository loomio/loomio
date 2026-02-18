require 'test_helper'

class IdentityServiceTest < ActiveSupport::TestCase
  setup do
    @identity_params = {
      identity_type: 'oauth',
      uid: 'oauth_user_123',
      email: 'oauthuser@example.com',
      name: 'OAuth User',
      access_token: 'token_123'
    }
  end

  test "creates new identity and new user when no user exists" do
    identity = IdentityService.link_or_create(
      identity_params: @identity_params,
      current_user: nil
    )

    assert_equal 'oauth_user_123', identity.uid
    assert_equal 'oauthuser@example.com', identity.email
    assert_not_nil identity.user
    assert_equal 'oauthuser@example.com', identity.user.email
    assert_equal 'OAuth User', identity.user.name
    assert_equal true, identity.user.email_verified
  end

  test "links identity to existing verified user" do
    existing_user = User.create!(
      email: 'existing@example.com',
      name: 'Existing User',
      email_verified: true,
      username: 'existinguser'
    )

    identity_params = @identity_params.merge(email: 'existing@example.com')

    identity = IdentityService.link_or_create(
      identity_params: identity_params,
      current_user: nil
    )

    assert_equal existing_user, identity.user
    assert_equal true, existing_user.reload.email_verified
    assert_equal 1, existing_user.identities.count
  end

  test "links identity to unverified user and marks email verified" do
    unverified_user = User.create!(
      email: 'unverified@example.com',
      name: 'Unverified User',
      email_verified: false,
      username: 'unverifieduser'
    )

    identity_params = @identity_params.merge(email: 'unverified@example.com')

    identity = IdentityService.link_or_create(
      identity_params: identity_params,
      current_user: nil
    )

    assert_equal unverified_user, identity.user
    assert_equal true, unverified_user.reload.email_verified
  end

  test "creates pending identity when user already signed in" do
    current_user = users(:normal_user)

    identity = IdentityService.link_or_create(
      identity_params: @identity_params,
      current_user: current_user
    )

    assert_nil identity.user_id  # Pending, not linked
    assert_equal 'oauthuser@example.com', identity.email
    assert_equal 0, current_user.identities.count  # Not linked to current user
  end

  test "returns existing identity if it exists" do
    user = users(:normal_user)
    existing_identity = Identity.create!(
      user: user,
      uid: 'oauth_user_123',
      identity_type: 'oauth',
      email: 'oauthuser@example.com',
      name: 'OAuth User'
    )

    identity = IdentityService.link_or_create(
      identity_params: @identity_params,
      current_user: nil
    )

    assert_equal existing_identity.id, identity.id
    assert_equal user, identity.user
  end
end
