# frozen_string_literal: true

class StrictIvars::Configuration
	def initialize
		@mutex = Mutex.new
		@include = []
		@exclude = []
	end

	#: (*String) -> void
	def include(*patterns)
		@mutex.synchronize do
			@include.concat(patterns)
		end
	end

	#: (*String) -> void
	def exclude(*patterns)
		@mutex.synchronize do
			@exclude.concat(patterns)
		end
	end

	#: (String) -> bool
	def match(path)
		path = File.absolute_path(path)
		return false if @exclude.any? { |pattern| File.fnmatch?(pattern, path) }
		return true if @include.any? { |pattern| File.fnmatch?(pattern, path) }
		false
	end
end
