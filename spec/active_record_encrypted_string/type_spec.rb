# frozen_string_literal: true

RSpec.describe ActiveRecordEncryptedString::Type do
  describe 'encryption and decryption' do
    shared_examples 'pass null or empty string to encrypted' do
      parameterized do
        where :value, :expected_value, size: 2 do
          [
            [nil, nil],
            ['', '']
          ]
        end

        with_them do
          it 'return nil after encryption/description' do
            subject

            # check values stored in database
            expect(instance.read_attribute_before_type_cast(:plain)).to eq plain
            expect(instance.read_attribute_before_type_cast(:encrypted)).to eq expected_value

            # check decryption
            new_instance = dummy_klass.find(instance.id)
            expect(new_instance.plain).to eq plain
            expect(new_instance.encrypted).to eq expected_value
          end
        end
      end
    end

    shared_examples 'pass existing values to encrypted' do
      parameterized do
        where :value, size: 8 do
          [
            ['test'],
            ['with_underscore'],
            ['with-hyphen'],
            ['with space'],
            ['123'],
            [123],
            ['🐱🐱🐱'],
            ['cat🐱cat🐱cat🐱cat']
          ]
        end

        with_them do
          it 'encrypt value without affecting other columns' do
            subject

            expect(instance.read_attribute_before_type_cast(:plain)).to eq plain
            expect(instance.read_attribute_before_type_cast(:encrypted)).to_not eq value
            expect(instance.read_attribute_before_type_cast(:encrypted).bytesize).to be > value.to_s.bytesize
          end

          it 'decrypt value without affecting other columns' do
            subject

            new_instance = dummy_klass.find(instance.id)
            expect(new_instance.plain).to eq plain
            expect(new_instance.encrypted).to eq value.to_s
          end
        end
      end
    end

    before(:all) do
      ActiveRecord::Base.connection.create_table('dummys') do |t|
        t.string :plain
        t.string :encrypted
      end
    end

    after(:all) do
      ActiveRecord::Base.connection.drop_table('dummys')
    end

    subject { instance.save! }
    let(:instance) { dummy_klass.new(plain: plain, encrypted: value) }
    let(:plain) { 'plain' }

    context 'encrypt with default salt' do
      before do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
          c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
        end
      end

      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string
        end
      end

      it_behaves_like 'pass null or empty string to encrypted'
      it_behaves_like 'pass existing values to encrypted'
    end

    context 'encrypt with another salt' do
      before do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
          c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
        end
      end

      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string, salt: 'another_salt'
        end
      end

      it_behaves_like 'pass null or empty string to encrypted'
      it_behaves_like 'pass existing values to encrypted'
    end

    context 'set error handler and fail decryption' do
      before do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
          c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
          c.decryption_error_handler = error_handler
        end

        encrypter_mock = instance_double(ActiveSupport::MessageEncryptor)
        allow(ActiveSupport::MessageEncryptor).to receive(:new).and_return(encrypter_mock)
        allow(encrypter_mock).to receive(:decrypt_and_verify).and_raise(StandardError)
        allow(encrypter_mock).to receive(:encrypt_and_sign).and_return(value)
      end

      after do
        ActiveRecordEncryptedString.configure do |c|
          c.decryption_error_handler = nil
        end
      end

      let(:error_handler) do
        ->(exception, value) {
          raise StandardError, error_msg
        }
      end
      let(:error_msg) { "raise #{StandardError} and value is #{value}" }
      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string
        end
      end
      let(:value) { 'encrypted value' }

      it 'call error_handler' do
        subject
        expect { instance.encrypted }.to raise_error(StandardError, error_msg)
      end
    end

    context 'does not set error handler and fail decryption' do
      before do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
          c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
        end

        encrypter_mock = instance_double(ActiveSupport::MessageEncryptor)
        allow(ActiveSupport::MessageEncryptor).to receive(:new).and_return(encrypter_mock)
        allow(encrypter_mock).to receive(:decrypt_and_verify).and_raise(StandardError)
        allow(encrypter_mock).to receive(:encrypt_and_sign).and_return(value)
      end

      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string
        end
      end
      let(:value) { 'encrypted value' }

      it 'call error_handler' do
        subject
        expect { instance.encrypted }.to_not raise_error
      end
    end
  end

  describe 'changed_in_place' do
    before(:all) do
      ActiveRecord::Base.connection.create_table('dummys') do |t|
        t.string :encrypted
      end

      ActiveRecordEncryptedString.configure do |c|
        c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
        c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
      end
    end

    after :all do
      ActiveRecord::Base.connection.drop_table('dummys')
    end

    subject { instance.save! }
    let(:instance) { dummy_klass.create!(encrypted: value) }
    let(:value) { :encrypted }
    let(:dummy_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'dummys'

        attribute :encrypted, :encrypted_string
      end
    end

    it 'should not update encryption if record did not changed' do
      # not passing by active record because type#serialize is called twice
      created_encrypted = ActiveRecord::Base.connection.execute dummy_klass.select(:encrypted).where(id: instance.id).to_sql
      created_encrypted = created_encrypted.first['encrypted']

      # when read, changed_in_place? is called
      # https://github.com/rails/rails/blob/v6.0.3.4/activemodel/lib/active_model/attribute.rb#L62-L64
      instance.encrypted # read
      instance.save! # save without any changes
      reload_saved_encrypted = ActiveRecord::Base.connection.execute dummy_klass.select(:encrypted).where(id: instance.id).to_sql
      reload_saved_encrypted = reload_saved_encrypted.first['encrypted']
      expect(created_encrypted).to eq(reload_saved_encrypted)
    end
  end
end
