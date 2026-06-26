require 'test_helper'

class PasskeyCredentialTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "requires credential data" do
    credential = PasskeyCredential.new(user: @user)

    assert_not credential.valid?
    assert credential.errors[:external_id].any?
    assert credential.errors[:public_key].any?
  end

  test "requires external id to be unique" do
    PasskeyCredential.create!(user: @user, external_id: 'credential-id', public_key: 'public-key')

    duplicate = PasskeyCredential.new(user: users(:admin), external_id: 'credential-id', public_key: 'other-public-key')

    assert_not duplicate.valid?
    assert duplicate.errors[:external_id].any?
  end
end
