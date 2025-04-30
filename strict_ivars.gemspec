# frozen_string_literal: true

require_relative "lib/strict_ivars/version"

Gem::Specification.new do |spec|
	spec.name = "strict_ivars"
	spec.version = StrictIvars::VERSION
	spec.authors = ["Joel Drapper"]
	spec.email = ["joel@drapper.me"]

	spec.summary = "Raise an exception when using undefined instance variables."
	spec.description = spec.summary
	spec.homepage = "https://github.com/joeldrapper/strict_ivars"
	spec.license = "MIT"
	spec.required_ruby_version = ">= 3.1"

	spec.metadata["homepage_uri"] = spec.homepage
	spec.metadata["source_code_uri"] = "https://github.com/joeldrapper/strict_ivars"
	spec.metadata["funding_uri"] = "https://github.com/sponsors/joeldrapper"

	spec.files = Dir[
		"README.md",
		"LICENSE.txt",
		"lib/**/*.rb"
	]

	spec.require_paths = ["lib"]

	spec.metadata["rubygems_mfa_required"] = "true"
	spec.add_dependency "require-hooks"
	spec.add_dependency "prism"
end
