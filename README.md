# ActiveRecordEncryptedString
Generates encrypted_string type that transparently encrypt and decrypt string value to ActiveRecord.

Support ActiveRecord 5.0 and later.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_encrypted_string'
```

And then execute:

```shell
bundle install
```


## Usage

Call ActiveRecord::Attribute API and specify `:encrypted_string` as type, then your database has encrypted value and application can get plain value.

```ruby
class User < ActiveRecord::Base
  attribute :name, :encrypted_string
end
```

Must configure secret_key and salt for encryption and decryption. You can also configure algorithm, pass the value to `cipher_alg`. `cipher_alg` has default value `aes-256-gcm` so you do not need to configure if you want to use `aes-256-gcm`.

```ruby
# config/initializers/active_record_encrypted_string.rb
ActiveRecordEncryptedString.configure do |c|
  c.secret_key = ENV['ENCRYPTION_SECRET_KEY'],
  c.salt = ENV['ENCRYPTION_SALT'],
  c.cipher_alg = 'aes-256-gcm'
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/active_record_encrypted_string. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/active_record_encrypted_string/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the ActiveRecordEncryptedString project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_record_encrypted_string/blob/master/CODE_OF_CONDUCT.md).
