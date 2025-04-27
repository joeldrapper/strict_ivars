# frozen_string_literal: true

require "require-hooks/setup"
require "prism"

module AyeVar
	NameError = Class.new(::NameError)

	def self.init(include: [], exclude: [])
		RequireHooks.source_transform(patterns: include, exclude_patterns: exclude) do |path, source|
			source ||= File.read(path)
			Processor.call(source)
		end
	end

	class Processor < Prism::Visitor
		def self.call(source)
			visitor = new
			visitor.visit(Prism.parse(source).value)

			buffer = source.dup

			visitor.annotations.sort_by(&:first).reverse_each do |offset, action, name|
				case action
				when :start
					buffer.insert(offset, "((raise ::AyeVar::NameError.new('Undefined instance variable #{name}') unless defined?(#{name}));")
				when :end
					buffer.insert(offset, ")")
				else
					raise "Invalid annotation"
				end
			end

			buffer
		end

		def initialize
			@definition_context = true
			@stack = [Set[]]
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

		def visit_def_node(node)
			new_context do
				if node.name == :initialize || node.name == :setup || Prism::SelfNode === node.receiver
					super
				else
					disallow_definitions { super }
				end
			end
		end

		def visit_if_node(node)
			visit(node.predicate)

			dup_context { visit(node.statements) }
			dup_context { visit(node.subsequent) }
		end

		def visit_case_node(node)
			visit(node.predicate)

			node.conditions.each do |condition|
				dup_context { visit(condition) }
			end

			dup_context { visit(node.else_clause) }
		end

		def visit_instance_variable_read_node(node)
			name = node.name

			unless context.include?(name)
				location = node.location

				context << name

				@annotations << [location.start_character_offset, :start, name]
				@annotations << [location.end_character_offset, :end, name]
			end

			super
		end

		def visit_instance_variable_write_node(node)
			name = node.name

			unless @definition_context || context.include?(name)
				location = node.location

				context << name

				@annotations << [location.start_character_offset, :start, name]
				@annotations << [location.end_character_offset, :end, name]
			end

			super
		end

		private def dup_context
			@stack.push(context.dup)

			begin
				yield
			ensure
				@stack.pop
			end
		end

		private def new_context
			@stack.push(Set[])

			begin
				yield
			ensure
				@stack.pop
			end
		end

		# The current context on the stack
		private def context
			@stack.last
		end

		private def disallow_definitions
			original_definition_context = @definition_context

			begin
				@definition_context = false
				yield
			ensure
				@definition_context = original_definition_context
			end
		end
	end
end
