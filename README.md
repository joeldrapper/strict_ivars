# StrictIvars

StrictIvars is a tiny pre-processor for Ruby that guards your instance variable reads, ensuring the instance variable is actually defined. This helps catch typos early.

## How does it work?

When StrictIvars detects that you are loading code from paths its configured to handle, it quickly looks for instance variable reads and guards them with a `defined?` check.

For example, it will replace this:

```ruby
def example
	foo if @bar
end
```

with something like this:

```ruby
	def example
		foo if (raise unless defined?(@bar); @bar)
	end
```

## Setup

Install the gem by adding it to your `Gemfile` and running `bundle install`. You may want to set it to `require: false` because you need to require it at the right moment.

```ruby
gem "strict_ivars", require: false
```

Then require and initialize the gem as early as possible in your boot process. Ideally, this should be right after bootsnap.

```ruby
require "strict_ivars"

StrictIvars.init(include: ["#{Dir.pwd}/**/*"])
```
