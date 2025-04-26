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

			buffer
		end

		def initialize
			@initializer = false
			@ivars = []
		end

		attr_reader :ivars

		def visit_def_node(node)
			if node.name == :initialize
				begin
					@initializer = true
					super
				ensure
					@initializer = false
				end
			else
				super
			end
		end

		def visit_instance_variable_read_node(node)
			location = node.location
			name = node.name

			@ivars << [location.start_character_offset, :start, name]
			@ivars << [location.end_character_offset, :end, name]
			super
		end

		def visit_instance_variable_write_node(node)
			unless @initializer
				location = node.location
				name = node.name

				@ivars << [location.start_character_offset, :start, name]
				@ivars << [location.end_character_offset, :end, name]
			end

			super
		end
	end

	private_constant :Processor

	NameError = Class.new(::NameError)

	def self.init(include: [], exclude: [])
		RequireHooks.source_transform(patterns: include, exclude_patterns: exclude) do |path, source|
			source ||= File.read(path)
			Processor.call(source)
		end
	end
end
