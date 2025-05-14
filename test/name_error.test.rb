# frozen_string_literal: true

class Example
	def initialize
		@username = 1
		@user = 2
		@user_favourites = 2
	end
end

test "suggestions" do
	assert_equal StrictIvars::NameError.new(Example.new, :@use).message,
		"Undefined instance variable `@use`. Did you mean `@user`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@users).message,
		"Undefined instance variable `@users`. Did you mean `@user`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@usre).message,
		"Undefined instance variable `@usre`. Did you mean `@user`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@usrenam).message,
		"Undefined instance variable `@usrenam`. Did you mean `@username`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@userna).message,
		"Undefined instance variable `@userna`. Did you mean `@username`?"

	assert_equal StrictIvars::NameError.new(Example.new, :@usrfavorits).message,
		"Undefined instance variable `@usrfavorits`. Did you mean `@user_favourites`?"
end
