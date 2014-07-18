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
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "virtus"
  spec.add_dependency "preamble", ">= 0.0.3"
  spec.add_dependency "archivist-client", ">= 0.1.7"
  spec.add_dependency "retriable"
  spec.add_dependency "simhash", "0.2.5"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "debugger"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
