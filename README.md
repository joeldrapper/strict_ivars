# Strict Ivars

Strict Ivars is a tiny pre-processor for Ruby that guards your instance variable reads, ensuring the instance variable is actually defined. This helps catch typos nice and early.

## How does it work?

When Strict Ivars detects that you are loading code from paths its configured to handle, it quickly looks for instance variable reads and guards them with a `defined?` check.

For example, it will replace this:

```ruby
def example
  foo if @bar
end
```

...with something like this:

```ruby
def example
  foo if (defined?(@bar) ? @bar : raise)
end
```

The replacement happens on load, so you never see this in your source code. It’s also always wrapped in parentheses and takes up a single line, so it won’t mess up the line numbers in exceptions.

## Setup

Install the gem by adding it to your `Gemfile` and running `bundle install`.

You may want to set it to `require: false` here because you should require it manually at precisely the right moment.

```ruby
gem "strict_ivars", require: false
```

Now the gem is installed, you should require and initialize the gem as early as possible in your boot process. Ideally, this should be right after bootsnap. In Rails, this will be in your `boot.rb` file.

```ruby
require "strict_ivars"

StrictIvars.init(include: ["#{Dir.pwd}/**/*"])
```
