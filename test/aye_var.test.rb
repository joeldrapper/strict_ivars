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

basic_object_example = BasicObjectExample.new

test "basic object undefined read" do
	assert_raises AyeVar::NameError do
		assert basic_object_example.foo
	end
end

test "basic object defined read" do
	refute_raises do
		assert_equal "bar", basic_object_example.bar
	end
end
