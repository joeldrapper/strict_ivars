# frozen_string_literal: true

class Example
	def initialize
		@bar = "bar"
	end

	def foo
		@foo
	end

	def foo=(value)
		@foo = value
	end

	def bar
		@bar
	end

	def bar=(value)
		@bar = value
	end
end
