# frozen_string_literal: true

test "the require hooks work" do
	require_relative "example"

	assert_raises StrictIvars::NameError do
		Example.new.foo
	end
end
