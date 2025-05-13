# frozen_string_literal: true

class Example
	def initialize
		@username = 1
		@user = 2
		@user_favourites = 2
	end
end

test "suggestions" do
	assert_equal StrictIvars::NameError.new(Example.new, :@u).message,
		"Undefined instance variable `@u`. Did you mean `@user`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@users).message,
		"Undefined instance variable `@users`. Did you mean `@user`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@userna).message,
		"Undefined instance variable `@userna`. Did you mean `@username`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@usrfavorits).message,
		"Undefined instance variable `@usrfavorits`. Did you mean `@user_favourites`?"
end
