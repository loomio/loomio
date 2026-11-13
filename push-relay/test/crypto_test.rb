require_relative "test_helper"

class CryptoTest < Minitest::Test
  def test_decrypts_existing_node_ciphertext_and_detects_tampering
    key = "\x07" * 32
    ciphertext = "AwMDAwMDAwMDAwMD.M-6T6x5ypKicdhydD_Di_w.QZvVajlNczEfIzE5nw"
    assert_equal "device-secret", PushRelay::Crypto.decrypt(ciphertext, key)
    assert_raises(OpenSSL::Cipher::CipherError) { PushRelay::Crypto.decrypt(ciphertext, "\x08" * 32) }
    assert_raises(ArgumentError) { PushRelay::Crypto.decrypt("invalid", key) }
    encrypted = PushRelay::Crypto.encrypt("device-secret", key)
    assert_equal "device-secret", PushRelay::Crypto.decrypt(encrypted, key)
    refute_includes encrypted, "device-secret"
  end

  def test_matches_original_protocol_signature_fixture
    values = { method: "POST", path: "/v1/registrations/123e4567-e89b-42d3-a456-426614174000/events",
      timestamp: "1700000000", nonce: "abcdefghijklmnopqrstuvwx", body: "{}", key: "b" * 43 }
    expected = "VxFDTrDV0r91XQIOcxlZN_nOmHar-IhKR1BE4xaW9O8"
    assert_equal expected, PushRelay::Crypto.signature(**values)
    assert PushRelay::Crypto.valid_signature?(expected, expected)
    refute PushRelay::Crypto.valid_signature?("bad", expected)
    refute PushRelay::Crypto.valid_signature?(PushRelay::Crypto.signature(**values.merge(body: "{ }")), expected)
  end
end
