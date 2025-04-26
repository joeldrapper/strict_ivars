# frozen_string_literal: true

require "require-hooks/setup"
require "prism"

module AyeVar
	class Processor < Prism::Visitor
		def self.call(source)
			visitor = new
			visitor.visit(Prism.parse(source).value)

			buffer = source.dup

			visitor.ivars.sort_by(&:first).reverse_each do |offset, action, name|
				case action
				when :start
					buffer.insert(offset, "((raise ::AyeVar::NameError.new('Undefined instance variable #{name}') unless defined?(#{name}));")
				when :end
					buffer.insert(offset, ")")
				end
			end

			puts buffer
			buffer
		end

		def initialize
			@definition_context = true
			@context = [Set[]]
			@ivars = []
		end

		attr_reader :ivars

		def visit_class_node(node)
			@context.push(Set[])
			super
		ensure
			@context.pop
		end

		def visit_module_node(node)
			@context.push(Set[])
			super
		ensure
			@context.pop
		end

		def visit_block_node(node)
			@context.push(Set[])
			super
		ensure
			@context.pop
		end

		def visit_singleton_class_node(node)
			@context.push(Set[])
			super
		ensure
			@context.pop
		end

		def visit_def_node(node)
			@context.push(Set[])

			if node.name == :initialize || node.name == :setup || Prism::SelfNode === node.receiver
				super
			else
				disallow_definitions { super }
			end
		ensure
			@context.pop
		end

		def visit_if_node(node)
			visit(node.predicate)

			@context.push(@context.last.dup)

			begin
				visit(node.statements)
			ensure
				@context.pop
			end

			@context.push(@context.last.dup)

			begin
				visit(node.subsequent)
			ensure
				@context.pop
			end
		end

		def visit_case_node(node)
			visit(node.predicate)

			node.conditions.each do |condition|
				@context.push(@context.last.dup)

				begin
					visit(condition)
				ensure
					@context.pop
				end
			end

			@context.push(@context.last.dup)
			begin
				visit(node.else_clause)
			ensure
				@context.pop
			end
		end

		def visit_instance_variable_read_node(node)
			name = node.name

			unless @context.last.include?(name)
				location = node.location

				@context.last << name

				@ivars << [location.start_character_offset, :start, name]
				@ivars << [location.end_character_offset, :end, name]
			end

			super
		end

		def visit_instance_variable_write_node(node)
			name = node.name

			unless @definition_context || @context.last.include?(name)
				location = node.location

				@context.last << name

				@ivars << [location.start_character_offset, :start, name]
				@ivars << [location.end_character_offset, :end, name]
			end

			super
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

	NameError = Class.new(::NameError)

	def self.init(include: [], exclude: [])
		RequireHooks.source_transform(patterns: include, exclude_patterns: exclude) do |path, source|
			source ||= File.read(path)
			Processor.call(source)
		end
	end
end
