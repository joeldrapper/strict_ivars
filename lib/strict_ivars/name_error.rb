# frozen_string_literal: true

require "did_you_mean/spell_checker"

class StrictIvars::NameError < ::NameError
	INSTANCE_VARIABLE_METHOD = Kernel.instance_method(:instance_variables)

	def initialize(object, name)
		checker = DidYouMean::SpellChecker.new(
			dictionary: INSTANCE_VARIABLE_METHOD.bind_call(object)
		)

		suggestion = checker.correct(name).first

		message = [
			"Undefined instance variable `#{name}`.",
			("Did you mean `#{suggestion}`?" if suggestion),
		].join(" ")

		super(message)
	end
end
