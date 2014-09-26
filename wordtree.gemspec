# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wordtree/version'

Gem::Specification.new do |spec|
  spec.name          = "wordtree"
  spec.version       = Wordtree::VERSION
  spec.authors       = ["Duane Johnson"]
  spec.email         = ["duane.johnson@gmail.com"]
  spec.description   = %q{WordTree common library code}
  spec.summary       = %q{Wordtree common library code}
  spec.homepage      = "https://github.com/wordtreefoundation/wordtree-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extensions    = %w[ext/extconf.rb]

  spec.add_dependency "virtus",   "~> 1.0"
  spec.add_dependency "preamble", "0.0.3"
  spec.add_dependency "archivist-client", "0.1.7"
  spec.add_dependency "retriable", "1.4.1"
  spec.add_dependency "simhash", "0.2.5"
  spec.add_dependency "rethinkdb", "~> 1.14"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "byebug", "~> 3.4"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "guard", "~> 2.6"
  spec.add_development_dependency "guard-rspec", "~> 4.3"
  spec.add_development_dependency "vcr", "~> 2.9"
  spec.add_development_dependency "webmock", "~> 1.18"
end
