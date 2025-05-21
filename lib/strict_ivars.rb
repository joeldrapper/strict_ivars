# frozen_string_literal: true

require "set"
require "prism"
require "securerandom"

require "strict_ivars/version"
require "strict_ivars/name_error"
require "strict_ivars/base_processor"
require "strict_ivars/processor"
require "strict_ivars/configuration"

require "require-hooks/setup"

module StrictIvars
	EMPTY_ARRAY = [].freeze
	EVERYTHING = ["**/*"].freeze
	METHOD_METHOD = Module.instance_method(:method)

	CONFIG = Configuration.new

	# Initializes StrictIvars so that code loaded after this point will be
	# guarded against undefined instance variable reads. You can pass an array
	# of globs to `include:` and `exclude:`.
	#
	# ```ruby
	# StrictIvars.init(
	#   include: ["#{Dir.pwd}/**/*"],
	#   exclude: ["#{Dir.pwd}/vendor/**/*"]
	# )
	# ```
	#: (include: Array[String], exclude: Array[String]) -> void
	def self.init(include: EMPTY_ARRAY, exclude: EMPTY_ARRAY)
		CONFIG.include(*include)
		CONFIG.exclude(*exclude)

		RequireHooks.source_transform(
			patterns: EVERYTHING,
			exclude_patterns: EMPTY_ARRAY
		) do |path, source|
			source ||= File.read(path)

			if CONFIG.match?(path)
				Processor.call(source)
			else
				BaseProcessor.call(source)
			end
		end
	end

	# For internal use only. This method pre-processes arguments to an eval method.
	#: (Object, Symbol, *untyped)
	def self.__process_eval_args__(receiver, method_name, *args)
		method = METHOD_METHOD.bind_call(receiver, method_name)
		owner = method.owner

		source, file = nil

		case method_name
		when :class_eval, :module_eval
			if Module == owner
				source, file = args
			end
		when :instance_eval
			if BasicObject == owner
				source, file = args
			end
		when :eval
			if Kernel == owner
				source, binding, file = args
			elsif Binding == owner
				source, file = args
			end
		end

		if String === source
			file ||= caller_locations(1, 1).first.path

			if CONFIG.match?(file)
				args[0] = Processor.call(source)
			else
				args[0] = BaseProcessor.call(source)
			end
		end

		args
	rescue ::NameError
		args
	end

	#: () { () -> void } -> Proc
	def self.__eval_block_from_forwarding__(*, &block)
		block
	end
end
