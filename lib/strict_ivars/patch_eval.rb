# frozen_string_literal: true

module StrictIvars
	module ModuleEvalPatch
		#: (String, ?String, ?Integer) -> void
		#: () { () -> void } -> void
		def class_eval(*args)
			source, file, lineno = args

			file ||= caller_locations(1, 1).first.path

			if source && file && CONFIG.match(file)
				args[0] = Processor.call(source)
			end

			super
		end

		#: (String, ?String, ?Integer) -> void
		#: () { () -> void } -> void
		def module_eval(*args)
			source, file, lineno = args

			file ||= caller_locations(1, 1).first.path

			if source && file && CONFIG.match(file)
				args[0] = Processor.call(source)
			end

			super
		end
	end

	module InstanceEvalPatch
		#: (String, ?String, ?Integer) -> void
		#: () { () -> void } -> void
		def instance_eval(*args)
			source, file, lineno = args

			file ||= caller_locations(1, 1).first.path

			if source && file && CONFIG.match(file)
				args[0] = Processor.call(source)
			end

			super
		end
	end

	module KernelEvalPatch
		#: (String, Binding, ?String, ?Integer) -> void
		def eval(*args)
			source, binding, file, lineno = args

			file ||= caller_locations(1, 1).first.path

			if source && file && CONFIG.match(file)
				args[0] = Processor.call(source.to_s)
			end

			super
		end
	end

	module BindingEvalPatch
		#: (String, ?String, ?Integer) -> void
		def eval(*args)
			source, file, lineno = args

			file ||= caller_locations(1, 1).first.path

			if source && file && CONFIG.match(file)
				args[0] = Processor.call(source.to_s)
			end

			super
		end
	end

	Kernel.prepend(KernelEvalPatch)
	Module.prepend(ModuleEvalPatch)
	Binding.prepend(BindingEvalPatch)
	BasicObject.prepend(InstanceEvalPatch)
end
