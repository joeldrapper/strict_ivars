# frozen_string_literal: true

class StrictIvars::Processor < Prism::Visitor
	def self.call(source)
		visitor = new
		visitor.visit(Prism.parse(source).value)
		buffer = source.dup
		annotations = visitor.annotations
		annotations.sort_by!(&:first)

		annotations.reverse_each do |offset, action, name|
			case action
			when :start
				buffer.insert(offset, "(defined?(#{name}) ? ")
			when :end
				buffer.insert(offset, " : (::Kernel.raise(::StrictIvars::NameError.new('Undefined instance variable #{name}'))))")
			else
				raise "Invalid annotation"
			end
		end

		buffer
	end

	def initialize
		@context = Set[]
		@annotations = []
	end

	attr_reader :annotations

	def visit_class_node(node)
		new_context { super }
	end

	def visit_module_node(node)
		new_context { super }
	end

	def visit_block_node(node)
		new_context { super }
	end

	def visit_singleton_class_node(node)
		new_context { super }
	end

	def visit_defined_node(node)
		value = node.value

		if Prism::InstanceVariableReadNode === value
			@context << value.name
		end

		super
	end

	def visit_def_node(node)
		new_context { super }
	end

	def visit_if_node(node)
		visit(node.predicate)

		branch { visit(node.statements) }
		branch { visit(node.subsequent) }
	end

	def visit_case_node(node)
		visit(node.predicate)

		node.conditions.each do |condition|
			branch { visit(condition) }
		end

		branch { visit(node.else_clause) }
	end

	def visit_instance_variable_read_node(node)
		name = node.name

		unless @context.include?(name)
			location = node.location

			@context << name

			@annotations <<
				[location.start_character_offset, :start, name] <<
				[location.end_character_offset, :end, name]
		end

		super
	end

	private def new_context
		original_context = @context

		@context = Set[]

		begin
			yield
		ensure
			@context = original_context
		end
	end

	private def branch
		original_context = @context
		@context = original_context.dup

		begin
			yield
		ensure
			@context = original_context
		end
	end
end
