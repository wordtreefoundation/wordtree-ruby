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
  spec.add_dependency "preambular", "0.3"
  spec.add_dependency "archdown", ">= 0.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "debugger"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
