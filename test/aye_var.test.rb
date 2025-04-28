# frozen_string_literal: true

AyeVar.init(include: ["#{Dir.pwd}/**/*"])

require_relative "example"

example = Example.new

test "undefined read" do
	assert_raises AyeVar::NameError do
		assert example.foo
	end
end

test "defined read" do
	refute_raises do
		assert_equal "bar", example.bar
	end
end
