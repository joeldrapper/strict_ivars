# frozen_string_literal: true

require "prism"
require "require-hooks/setup"
require "strict_ivars/version"
require "strict_ivars/processor"
require "strict_ivars/configuration"

module StrictIvars
	NameError = Class.new(::NameError)

	CONFIG = Configuration.new

	#: (include: Array[String], exclude: Array[String]) -> void
	def self.init(include: [], exclude: [])
		CONFIG.include(*include)
		CONFIG.exclude(*exclude)

		RequireHooks.source_transform(
			patterns: include,
			exclude_patterns: exclude
		) do |path, source|
			source ||= File.read(path)
			Processor.call(source)
		end
	end
end
