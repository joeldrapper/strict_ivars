# frozen_string_literal: true

module ExampleModule
	module_eval <<~RUBY, __FILE__, __LINE__ + 1
		def self.included
			@included
		end
	RUBY

	module_eval <<~RUBY, "./excluded.rb", __LINE__ + 1
		def self.excluded
			@excluded
		end
	RUBY

	module_eval <<~RUBY
		def self.implicit
			@implicit
		end
	RUBY
end

class ExampleClass
	module_eval <<~RUBY, __FILE__, __LINE__ + 1
		def self.included
			@included
		end
	RUBY

	module_eval <<~RUBY, "./excluded.rb", __LINE__ + 1
		def self.excluded
			@excluded
		end
	RUBY

	module_eval <<~RUBY
		def self.implicit
			@implicit
		end
	RUBY
end

test "on a module with an included file" do
	assert_raises StrictIvars::NameError do
		ExampleModule.included
	end
end

test "on a module with an excluded file" do
	refute_raises do
		ExampleModule.excluded
	end
end

test "on a module with implicit path from an included file" do
	assert_raises StrictIvars::NameError do
		ExampleModule.implicit
	end
end

test "on a class with an included file" do
	assert_raises StrictIvars::NameError do
		ExampleClass.included
	end
end

test "on a class with an excluded file" do
	refute_raises do
		ExampleClass.excluded
	end
end

test "on a class with implicit path from an included file" do
	assert_raises StrictIvars::NameError do
		ExampleClass.implicit
	end
end
