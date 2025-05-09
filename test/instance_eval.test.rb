# frozen_string_literal: true

class ExampleClass
	def included
		instance_eval <<~RUBY, __FILE__, __LINE__ + 1
			@included
		RUBY
	end

	def excluded
		instance_eval <<~RUBY, "./excluded.rb", __LINE__ + 1
			@included
		RUBY
	end

	def unknown
		instance_eval <<~RUBY
			@unknown
		RUBY
	end
end

module ExampleModule
end

test "with an included file" do
	assert_raises StrictIvars::NameError do
		ExampleClass.new.included
	end
end

test "with an excluded file" do
	refute_raises do
		ExampleClass.new.excluded
	end
end

test "with no path from an included file" do
	assert_raises StrictIvars::NameError do
		ExampleClass.new.unknown
	end
end

test "on class singleton" do
	assert_raises StrictIvars::NameError do
		ExampleClass.instance_eval("@hello")
	end
end

test "on module singleton" do
	assert_raises StrictIvars::NameError do
		ExampleModule.instance_eval("@hello")
	end
end
