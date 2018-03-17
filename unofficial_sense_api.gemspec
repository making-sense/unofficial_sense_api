# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sense_api/version"

Gem::Specification.new do |spec|
  spec.name          = "unofficial_sense_api"
  spec.version       = SenseApi::VERSION
  spec.authors       = ["Making Sense"]

  spec.summary       = %q{Get access to your home's power data from Sense}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "json"
  spec.add_dependency "eventmachine"
  spec.add_dependency "websocket-eventmachine-client"
end
