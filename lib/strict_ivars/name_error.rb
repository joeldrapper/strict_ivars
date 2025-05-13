# frozen_string_literal: true

class StrictIvars::NameError < ::NameError
	InstanceVariablesMethod = Kernel.instance_method(:instance_variables)

	def initialize(object, name)
		suggestion = InstanceVariablesMethod.bind_call(object).max_by { |it| n_common_trigrams(it, name).to_f / Math.sqrt(it.length) }

		super(
			[
				"Undefined instance variable `#{name}`.",
				("Did you mean `#{suggestion}`?" if suggestion),
			].join(" ")
		)
	end

	private def n_common_trigrams(left, right)
		left = "\x03\x02#{left}"
		right = "\x03\x02#{right}"

		left_len = left.length
		right_len = right.length

		return 0 if left_len < 3 || right_len < 3

		# Process shorter string first
		if left_len > right_len
			left, right = right, left
			left_len, right_len = right_len, left_len
		end

		# Use a Set for lookup
		trigrams = Set.new
		count = 0

		# Generate trigrams from shorter string
		i = 0
		left_max = left_len - 2
		while i < left_max
			trigram = left[i, 3]
			trigrams.add(trigram)
			i += 1
		end

		# Check trigrams from longer string
		i = 0
		right_max = right_len - 2
		while i < right_max
			count += 1 if trigrams.include?(right[i, 3])
			i += 1
		end

		count
	end
end
