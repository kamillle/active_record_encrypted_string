# frozen_string_literal: true

module ActiveRecordEncryptedString
  class Configuration
    attr_accessor :secret_key, :salt, :cipher_alg, :decryption_error_handler

    def initialize
      @cipher_alg = 'aes-256-gcm'
    end

    def defined_decryption_error_handler?
      return false if decryption_error_handler.nil?

      decryption_error_handler.respond_to?(:call)
    end
  end
end
