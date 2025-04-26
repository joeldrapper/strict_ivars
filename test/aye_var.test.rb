# frozen_string_literal: true

AyeVar.init(include: ["#{Dir.pwd}/**/*"])

require_relative "example"

example = Example.new

test "undefined write in singleton" do
	refute_raises do
		assert_equal 1, Example.bar
	end
end

test "undefined read" do
	assert_raises AyeVar::NameError do
		assert example.foo
	end
end

test "undefined write" do
	assert_raises AyeVar::NameError do
		assert example.foo = 1
	end
end

test "defined read" do
	refute_raises do
		assert_equal "bar", example.bar
	end
end

test "defined write" do
	refute_raises do
		assert_equal 1, example.bar = 1
	end
end
