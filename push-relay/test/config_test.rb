require_relative "test_helper"

class ConfigTest < Minitest::Test
  def environment
    { "LOOMIO_DATABASE_PATH" => "/tmp/relay.sqlite3", "RELAY_ENCRYPTION_KEY" => Base64.strict_encode64(SecureRandom.random_bytes(32)),
      "APNS_TEAM_ID" => "ABCDE12345", "APNS_KEY_ID" => "PRODKEY123", "APNS_TOPIC" => "org.loomio.mobile",
      "APNS_PRIVATE_KEY" => OpenSSL::PKey::EC.generate("prime256v1").private_to_pem }
  end

  def test_requires_valid_encryption_and_signing_keys_and_database_path
    env = environment
    assert_equal "/tmp/relay.sqlite3", PushRelay::Config.new(env).database_path
    [env.merge("RELAY_ENCRYPTION_KEY" => "bad-base64"), env.merge("RELAY_ENCRYPTION_KEY" => Base64.strict_encode64("short")),
      env.merge("APNS_PRIVATE_KEY" => "invalid"), env.merge("APNS_TEAM_ID" => "bad"), env.merge("LOOMIO_DATABASE_PATH" => ""),
      env.merge("APNS_PRIVATE_KEY" => OpenSSL::PKey::EC.generate("secp384r1").private_to_pem)].each do |invalid|
      assert_raises(ArgumentError) { PushRelay::Config.new(invalid) }
    end
  end

  def test_boolean_flags_use_presence
    env = environment
    refute PushRelay::Config.new(env).allow_private_hosts
    assert PushRelay::Config.new(env.merge("ALLOW_PRIVATE_HOSTS" => "0")).allow_private_hosts
  end

  def test_separate_sandbox_credentials_must_be_complete
    env = environment.merge("APNS_SANDBOX_KEY_ID" => "SANDKEY123")
    assert_raises(ArgumentError) { PushRelay::Config.new(env) }
    env["APNS_SANDBOX_PRIVATE_KEY"] = OpenSSL::PKey::EC.generate("prime256v1").private_to_pem
    config = PushRelay::Config.new(env)
    assert_equal "SANDKEY123", config.apns.fetch(:sandbox).fetch(:key_id)
    refute_equal config.apns.fetch(:production).fetch(:private_key).public_to_der,
      config.apns.fetch(:sandbox).fetch(:private_key).public_to_der
    env.delete("APNS_SANDBOX_KEY_ID")
    assert_raises(ArgumentError) { PushRelay::Config.new(env) }
  end

  def test_mounted_keys_are_read_and_ambiguous_sources_rejected
    Dir.mktmpdir do |directory|
      env = environment
      path = File.join(directory, "key.p8")
      File.write(path, env.fetch("APNS_PRIVATE_KEY"), mode: "w", perm: 0o600)
      env["APNS_PRIVATE_KEY_FILE"] = path
      assert_raises(ArgumentError) { PushRelay::Config.new(env) }
      env.delete("APNS_PRIVATE_KEY")
      assert PushRelay::Config.new(env).apns.fetch(:production).fetch(:private_key).private?
    end
  end
end
