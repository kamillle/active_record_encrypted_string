# frozen_string_literal: true

require_relative 'lib/active_record_encrypted_string/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_record_encrypted_string'
  spec.version       = ActiveRecordEncryptedString::VERSION
  spec.authors       = ['kamillle']
  spec.email         = ['32205171+kamillle@users.noreply.github.com']

  spec.summary       = 'Generates encrypted_string type that transparently encrypt and decrypt string value to ActiveRecord.'
  spec.description   = 'Generates encrypted_string type that transparently encrypt and decrypt string value to ActiveRecord.'
  spec.homepage      = 'https://github.com/kamillle/active_record_encrypted_string'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kamillle/active_record_encrypted_string'
  spec.metadata['changelog_uri'] = 'https://github.com/kamillle/active_record_encrypted_string/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 5.0', '< 7'
  spec.add_dependency 'activesupport', '< 7'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-parameterized'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
end
