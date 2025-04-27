# frozen_string_literal: true

require "require-hooks/setup"
require "prism"

module AyeVar
	METHODS_PERMITTED_FOR_DEFINITION = Set[:initialize, :setup].freeze

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
			@this = nil
			@context = nil
			@annotations = []
		end

		attr_reader :annotations

		def visit_class_node(node)
			new_context(node) { super }
		end

		def visit_module_node(node)
			new_context(node) { super }
		end

		def visit_block_node(node)
			new_context(node) { super }
		end

		def visit_singleton_class_node(node)
			new_context(node) { super }
		end

		def visit_def_node(node)
			parent = @this

			new_context(node) do
				if METHODS_PERMITTED_FOR_DEFINITION.include?(node.name) || Prism::SelfNode === node.receiver || !(Prism::ClassNode === parent)
					super
				else
					prevent_definitions { super }
				end
			end
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

		private def new_context(this)
			original_this = @this
			original_context = @context

			@this = this
			@context = Set[]

			begin
				yield
			ensure
				@this = original_this
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

		# The current context on the stack
		private def context
			@context
		end

		private def prevent_definitions
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
