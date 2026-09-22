require 'test_helper'

class RedactUserWorkerTest < ActiveSupport::TestCase
  test "permanently removes passkeys and their account user handle" do
    user = User.create!(name: "Redacted User", email: "redacted-passkeys@example.com", email_verified: true)
    PasskeyService.ensure_webauthn_id!(user)
    user.passkey_credentials.create!(
      external_id: "redacted-passkey",
      public_key: "redacted-public-key",
      user_handle: user.webauthn_id,
      sign_count: 0,
      name: "Redacted passkey"
    )

    assert_difference "PasskeyCredential.count", -1 do
      RedactUserWorker.perform_now(user.id, user.id, false)
    end

    assert_nil user.reload.webauthn_id
  end
end
