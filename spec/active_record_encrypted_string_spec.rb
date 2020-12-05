# frozen_string_literal: true

RSpec.describe ActiveRecordEncryptedString do
  describe 'version' do
    it 'has a version number' do
      expect(ActiveRecordEncryptedString::VERSION).not_to be nil
    end
  end

  describe '.configure' do
    let(:secret_key) { 'secret_key' }
    let(:salt) { 'salt' }

    context 'do not pass cipher_alg' do
      subject(:configuration) do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = secret_key
          c.salt = salt
        end
        ActiveRecordEncryptedString.configuration
      end

      it do
        expect(configuration.secret_key).to eq secret_key
        expect(configuration.salt).to eq salt
        expect(configuration.cipher_alg).to eq 'aes-256-gcm'
      end
    end

    context 'pass cipher_alg' do
      subject(:configuration) do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = secret_key
          c.salt = salt
          c.cipher_alg = cipher_alg
        end
        ActiveRecordEncryptedString.configuration
      end

      let(:cipher_alg) { 'aes-256-cbc' }

      it do
        expect(configuration.secret_key).to eq secret_key
        expect(configuration.salt).to eq salt
        expect(configuration.cipher_alg).to eq cipher_alg
      end
    end
  end

  describe 'encryption and decryption' do
    shared_examples 'pass null or empty string to encrypted' do
      where :value, :expected_value do
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

    shared_examples 'pass existing values to encrypted' do
      where :value do
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

    before(:all) do
      ActiveRecord::Base.connection.create_table('dummys') do |t|
        t.string :plain
        t.string :encrypted
      end

      ActiveRecordEncryptedString.configure do |c|
        c.secret_key = '5b13d146feab83d630313732178c2b782e9eb54f3db492b24b2afc084a6e6cc38aa61d100230426890df16f8f0440454eeeb9029beab5b47b2490e8a375657f8'
        c.salt = 'de71bee5d2dc788bec68f6cd691480216c2804bb6aacef8966a14b3a430f9803bb2530d32da366c4d3bd46deb851a494b57de423892bd554e4a8e338f2a06da8'
      end
    end

    subject { instance.save! }
    let(:instance) { dummy_klass.new(plain: plain, encrypted: value) }
    let(:plain) { 'plain' }

    context 'no changes encryption' do
      let(:value) { :encrypted }
      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string
        end
      end

      it 'should not update encrypted when not changed' do
        instance.save!
        expect { instance.save! }.not_to change { instance.read_attribute_before_type_cast(:encrypted) } # rubocop:disable Lint/AmbiguousBlockAssociation
      end
    end

    context 'encrypt with default salt' do
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
      let(:dummy_klass) do
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummys'

          attribute :encrypted, :encrypted_string, salt: 'another_salt'
        end
      end

      it_behaves_like 'pass null or empty string to encrypted'
      it_behaves_like 'pass existing values to encrypted'
    end
  end
end
