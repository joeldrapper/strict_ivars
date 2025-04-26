# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :test do
	gem "quickdraw", github: "joeldrapper/quickdraw"
	gem "simplecov", require: false, platform: :ruby
end

group :development do
	gem "rubocop", platform: :ruby
	gem "ruby-lsp", platform: :ruby
end

gem "irb"
