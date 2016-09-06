# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-addressbook/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "motion-addressbook"
  gem.version       = Motion::Addressbook::VERSION
  gem.license       = 'MIT'

  gem.authors       = ["Alex Rothenberg", "Jason May", "Jonathan Bender"]
  gem.email         = ["alex@alexrothenberg.com", "jmay@pobox.com", "jlbender@gmail.com"]
  gem.description   = %q{A RubyMotion wrapper around the ABAddressBook and CNContact frameworks}
  gem.summary       = %q{A RubyMotion wrapper around the ABAddressBook and CNContact frameworks}
  gem.homepage      = "https://github.com/alexrothenberg/motion-addressbook"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'newclear'
  gem.add_development_dependency 'motion-spec'
end
