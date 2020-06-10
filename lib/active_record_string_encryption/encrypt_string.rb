# frozen_string_literal: true

module ActiveRecordStringEncryption
  class EncryptString < ActiveRecord::Type::String
    CIPHER_ALG = 'aes-256-gcm'
    CIPHER_KEY_LENGTH = ActiveSupport::MessageEncryptor.key_len(CIPHER_ALG)

    def initialize(**options)
      @secret_key_base = 'dummy'
      @salt = options[:salt] || 'salt'
    end

    # ActiveRecord calls `serialize` to convert Ruby objects to a format that can be understood by database
    def serialize(value)
      # expects same behavior as ActiveRecord::Type::String other than encryption
      # https://github.com/rails/rails/blob/5-0-stable/activemodel/lib/active_model/type/immutable_string.rb
      v = super(value)
      encryptor.encrypt_and_sign(v) if v.present?
    end

    # ActiveRecord calls `deserialize` to convert values stored database to Ruby objects
    def deserialize(value)
      # expects same behavior as ActiveRecord::Type::String other than decryption
      # https://github.com/rails/rails/blob/5-0-stable/activemodel/lib/active_model/type/value.rb#L21-L23
      v = super(value)
      encryptor.decrypt_and_verify(v) if v.present?
    end

    private

    attr_reader :secret_key_base, :salt

    def encryptor
      # TODO: rotate
      ActiveSupport::MessageEncryptor.new(secret, cipher: CIPHER_ALG)
    end

    def secret
      ActiveSupport::KeyGenerator.new(secret_key_base).generate_key(salt, CIPHER_KEY_LENGTH)
    end
  end
end
