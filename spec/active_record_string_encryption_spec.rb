# frozen_string_literal: true

RSpec.describe ActiveRecordStringEncryption do
  describe 'version' do
    it 'has a version number' do
      expect(ActiveRecordStringEncryption::VERSION).not_to be nil
    end
  end

  describe 'encryption and decryption' do
    before(:all) do
      ActiveRecord::Base.connection.create_table('dummys') do |t|
        t.string :plain
        t.string :encrypted
      end
    end

    let(:dummy_klass) do
      Class.new(ActiveRecord::Base) do
        self.table_name = 'dummys'

        attribute :encrypted, :encrypt_string
      end
    end
    let(:instance) { dummy_klass.new(plain: plain, encrypted: value) }
    let(:plain) { 'plain' }

    context 'pass null or empty string to encrypted' do
      where :value do
        [
          nil,
          ''
        ]
      end

      subject { instance.save! }

      with_them do
        it 'return nil after encryption/description' do
          subject

          # check values stored in database
          expect(instance.read_attribute_before_type_cast(:plain)).to eq plain
          expect(instance.read_attribute_before_type_cast(:encrypted)).to eq nil

          # check decryption
          new_instance = dummy_klass.find(instance.id)
          expect(new_instance.plain).to eq plain
          expect(new_instance.encrypted).to eq nil
        end
      end
    end

    context 'pass existing values to encrypted' do
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

      subject { instance.save! }

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
end
