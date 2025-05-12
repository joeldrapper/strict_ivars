# frozen_string_literal: true

test "instance_eval with a receiver and forwarding" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		def foo
			bar.instance_eval(...)
		end
	RUBY

	receiver_id = processed[/__eval_receiver_(.+?)__/, 1]

	assert_equal_ruby processed, <<~RUBY
		def foo
			(__eval_receiver_#{receiver_id}__ = bar).instance_eval(*(::StrictIvars.__process_eval_args__(__eval_receiver_#{receiver_id}__, :instance_eval, ...)), &(::StrictIvars.__eval_block_from_forwarding__(...)))
		end
	RUBY
end

test "instance_eval with a receiver and literals" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		def foo
			bar.instance_eval("a", "b")
		end
	RUBY

	receiver_id = processed[/__eval_receiver_(.+?)__/, 1]

	assert_equal_ruby processed, <<~RUBY
		def foo
			(__eval_receiver_#{receiver_id}__ = bar).instance_eval(*(::StrictIvars.__process_eval_args__(__eval_receiver_#{receiver_id}__, :instance_eval, "a", "b")))
		end
	RUBY
end

test "instance_eval with a receiver and variables" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		def foo
			bar.instance_eval(a, b)
		end
	RUBY

	receiver_id = processed[/__eval_receiver_(.+?)__/, 1]

	assert_equal_ruby processed, <<~RUBY
		def foo
			(__eval_receiver_#{receiver_id}__ = bar).instance_eval(*(::StrictIvars.__process_eval_args__(__eval_receiver_#{receiver_id}__, :instance_eval, a, b)))
		end
	RUBY
end

test "class_eval with variables" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval(a, b)
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(*(::StrictIvars.__process_eval_args__(self, :class_eval, a, b)))
	RUBY
end

test "class_eval with literals" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval("a", "b")
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(*(::StrictIvars.__process_eval_args__(self, :class_eval, "a", "b")))
	RUBY
end

test "class_eval with *args" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval(*args)
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(*(::StrictIvars.__process_eval_args__(self, :class_eval, *args)))
	RUBY
end

test "class_eval with *" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval(*)
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(*(::StrictIvars.__process_eval_args__(self, :class_eval, *)))
	RUBY
end

test "class_eval with &block" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval(&block)
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(&block)
	RUBY
end

test "class_eval with &" do
	processed = StrictIvars::BaseProcessor.call(<<~RUBY)
		class_eval(&)
	RUBY

	assert_equal_ruby processed, <<~RUBY
		class_eval(&)
	RUBY
end
