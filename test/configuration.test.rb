# frozen_string_literal: true

test do
	config = StrictIvars::Configuration.new
	config.include("#{Dir.pwd}/lib/**/*.rb")
	config.exclude("#{Dir.pwd}/lib/**/version.rb")

	assert config.match?("lib/strict_ivars/name_error.rb")
	refute config.match?("lib/strict_ivars/version.rb")
	refute config.match?(Object.new)
	refute config.match?(nil)
end
