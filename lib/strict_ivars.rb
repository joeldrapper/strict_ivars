# frozen_string_literal: true

require "prism"
require "require-hooks/setup"

module StrictIvars
	NameError = Class.new(::NameError)

	#: (include: Array[String], exclude: Array[String]) -> void
	def self.init(include: [], exclude: [])
		RequireHooks.source_transform(
			patterns: include,
			exclude_patterns: exclude
		) do |path, source|
			source ||= File.read(path)
			Processor.call(source)
		end
	end
end

require "strict_ivars/processor"
