class Mobile::RelayCredentialCipher
  class << self
    def encrypt(value)
      encryptor.encrypt_and_sign(value)
    end

    def decrypt(value)
      encryptor.decrypt_and_verify(value)
    end

    private

    def encryptor
      @encryptor ||= begin
        key = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base).generate_key(
          "loomio-mobile-relay-delivery-key-v1",
          ActiveSupport::MessageEncryptor.key_len
        )
        ActiveSupport::MessageEncryptor.new(key)
      end
    end
  end
end
