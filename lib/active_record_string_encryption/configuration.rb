# frozen_string_literal: true

module ActiveRecordStringEncryption
  class Configuration
    attr_accessor :secret_key, :salt, :cipher_alg

    def initialize
      @cipher_alg = 'aes-256-gcm'
    end
  end
end
