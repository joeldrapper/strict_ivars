# frozen_string_literal: true

class Example
	def initialize
		@bar = "bar"
	end

	def foo
		@foo
	end

	def bar
		@bar
	end

	def baz
		if defined?(@bar)
			"baz"
		end
	end
end

class BasicObjectExample < BasicObject
	def initialize
		@bar = "bar"
	end

	def foo
		@foo
	end

	def bar
		@bar
	end
end

example = Example.new

test "undefined read" do
	assert_raises StrictIvars::NameError do
		assert example.foo
	end
end

test "defined read" do
	refute_raises do
		assert_equal "bar", example.bar
	end
end

test "defined?" do
	refute_raises do
		assert_equal "baz", example.baz
	end
end

basic_object_example = BasicObjectExample.new

test "basic object undefined read" do
	assert_raises StrictIvars::NameError do
		assert basic_object_example.foo
	end
end

test "basic object defined read" do
	refute_raises do
		assert_equal "bar", basic_object_example.bar
	end
end

test "__process_eval_args__ with nonsense method name" do
	assert_equal StrictIvars.__process_eval_args__(Object.new, :random_name, 1, 2, three: 3), [
		1,
		2,
		three: 3,
	]
end

test "__process_eval_args__ with non eval method name" do
	assert_equal StrictIvars.__process_eval_args__(Object.new, :to_s, 1, 2, three: 3), [
		1,
		2,
		three: 3,
	]
end
