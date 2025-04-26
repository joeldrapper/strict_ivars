# frozen_string_literal: true

class Example
	class << self
		def foo
			@foo = 1
		end
	end

	def initialize
		@bar = "bar"
	end

	def self.bar
		@bar = 1
	end

	def foo
		@foo = 1
		@foo = 2
		@foo = 3
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
