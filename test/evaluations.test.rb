# frozen_string_literal: true

class WithOverrides
	def self.class_eval(*a, **k, &b)
		["overridden class_eval", a, k, b]
	end

	def self.module_eval(*a, **k, &b)
		["overridden module_eval", a, k, b]
	end

	def self.instance_eval(*a, **k, &b)
		["overridden instance_eval", a, k, b]
	end

	def self.eval(*a, **k, &b)
		["overridden eval", a, k, b]
	end
end

module WithForwarding
	def self.foo = "bar"

	def self.forwarded_eval(...)
		class_eval(...)
	end
end

test "when the methods have been overridden" do
	assert_equal ["overridden class_eval", ["self.class"], {}, nil], WithOverrides.class_eval("self.class")
	assert_equal ["overridden module_eval", ["self.class"], {}, nil], WithOverrides.module_eval("self.class")
	assert_equal ["overridden instance_eval", ["self.class"], {}, nil], WithOverrides.instance_eval("self.class")
	assert_equal ["overridden eval", ["self.class"], {}, nil], WithOverrides.eval("self.class")
end

test "forwarding without a block" do
	assert_equal "bar", WithForwarding.forwarded_eval("foo")
end

test "forwarding with a block" do
	assert_equal "bar", WithForwarding.forwarded_eval { foo }
end
