# frozen_string_literal: true

class StrictIvars::BaseProcessor < Prism::Visitor
	EVAL_METHODS = Set[:class_eval, :module_eval, :instance_eval, :eval].freeze

	#: (String) -> String
	def self.call(source)
		visitor = new
		visitor.visit(Prism.parse(source).value)
		buffer = source.dup
		annotations = visitor.annotations
		annotations.sort_by!(&:first)

		annotations.reverse_each do |offset, string|
			buffer.insert(offset, string)
		end

		buffer
	end

	def initialize
		@context = Set[]
		@annotations = []
	end

	#: Array[[Integer, String]]
	attr_reader :annotations

	def visit_call_node(node)
		name = node.name

		if EVAL_METHODS.include?(name) && (arguments = node.arguments)
			location = arguments.location

			closing = if arguments.contains_forwarding?
				")), &(::StrictIvars.__eval_block_from_forwarding__(...))"
			else
				"))"
			end

			if node.receiver
				receiver_local = "__eval_receiver_#{SecureRandom.hex(8)}__"
				receiver_location = node.receiver.location

				@annotations.push(
					[receiver_location.start_character_offset, "(#{receiver_local} = "],
					[receiver_location.end_character_offset, ")"],
					[location.start_character_offset, "*(::StrictIvars.__process_eval_args__(#{receiver_local}, :#{name}, "],
					[location.end_character_offset, closing]
				)
			else
				@annotations.push(
					[location.start_character_offset, "*(::StrictIvars.__process_eval_args__(self, :#{name}, "],
					[location.end_character_offset, closing]
				)
			end
		end

		super
	end
end
