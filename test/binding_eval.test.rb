# frozen_string_literal: true

test "binding eval with included path" do
	assert_raises StrictIvars::NameError do
		binding.eval <<~RUBY, __FILE__, __LINE__ + 1
			@hello
		RUBY
	end
end

test "binding eval with excluded path" do
	refute_raises do
		binding.eval <<~RUBY, "./excluded.rb", __LINE__ + 1
			@hello
		RUBY
	end
end

test "binding eval with implicit path" do
	assert_raises StrictIvars::NameError do
		binding.eval <<~RUBY
			@hello
		RUBY
	end
end
