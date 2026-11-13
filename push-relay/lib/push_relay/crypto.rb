require "openssl"
require "base64"
require "digest"
require "securerandom"

module PushRelay
  module Crypto
    module_function

    def encrypt(value, key)
      cipher = OpenSSL::Cipher.new("aes-256-gcm").encrypt
      cipher.key = key
      iv = SecureRandom.random_bytes(12)
      cipher.iv = iv
      ciphertext = cipher.update(value) + cipher.final
      [iv, cipher.auth_tag, ciphertext].map { |part| Base64.urlsafe_encode64(part, padding: false) }.join(".")
    end

    def decrypt(value, key)
      parts = value.split(".", -1)
      raise ArgumentError, "invalid ciphertext" unless parts.size == 3
      iv, tag, ciphertext = parts.map { |part| Base64.urlsafe_decode64(part) }
      raise ArgumentError, "invalid ciphertext" unless iv.bytesize == 12 && tag.bytesize == 16
      cipher = OpenSSL::Cipher.new("aes-256-gcm").decrypt
      cipher.key = key
      cipher.iv = iv
      cipher.auth_tag = tag
      cipher.update(ciphertext) + cipher.final
    end

    def token_digest(value, key)
      OpenSSL::HMAC.hexdigest("SHA256", key, value).force_encoding(Encoding::US_ASCII)
    end

    def signature(method:, path:, timestamp:, nonce:, body:, key:)
      canonical = [method.upcase, path, timestamp, nonce, Digest::SHA256.hexdigest(body)].join("\n")
      Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", key, canonical), padding: false)
    end

    def valid_signature?(candidate, expected)
      candidate.is_a?(String) && candidate.bytesize == expected.bytesize &&
        OpenSSL.fixed_length_secure_compare(candidate, expected)
    end
  end
end
