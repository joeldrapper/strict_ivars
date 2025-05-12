# Strict Ivars

Strict Ivars is a tiny pre-processor for Ruby that guards your instance variable reads, ensuring the instance variable is actually defined. This helps catch typos nice and early. It‘s especially good when used with [Literal](https://literal.fun) and [Phlex](https://www.phlex.fun), though it also works with ERB.

> [!NOTE]  
> JRuby and TruffleRuby are not currently supported.

## Setup

Strict Ivars should be used in apps not libraries. Though you could use it in your library’s test suite.

Install the gem by adding it to your `Gemfile` and running `bundle install`. You’ll probably want to set it to `require: false` here because you should require it manually at precisely the right moment.

```ruby
gem "strict_ivars", require: false
```

Now the gem is installed, you should require and initialize the gem as early as possible in your boot process. Ideally, this should be right after Bootsnap is set up. In Rails, this will be in your `boot.rb` file.

```ruby
require "strict_ivars"
```

You can pass an array of globs to `StrictIvars.init` as `include:` and `exclude:`

```ruby
StrictIvars.init(include: ["#{Dir.pwd}/**/*"], exclude: ["#{Dir.pwd}/vendor/**/*"])
```

This example include everything in the current directory apart from the `./vendor` folder (which is where GitHub Actions installs gems).

If you’re using Bootsnap, you should clear your bootsnap cache by deleting the folder `tmp/cache/bootsnap`.

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

**Writes:**

Strict Ivars doesn’t apply to writes, since these are considered the authoritative source of the instance variable definitions.

```ruby
@foo = 1
```

**Or-writes:**

Or-writes are considered an authoritative definition, not a read.

```ruby
@foo ||= 1
```

**And-writes:**

And-writes are considered an authoritative definition, not a read.

```ruby
@foo &&= 1
```

## Common issues

#### Implicitly depending on undefined instance variables

```ruby
def description
  return @description if @description.present?
  @description = get_description
end
```

This example is relying on Ruby’s behaviour of returning `nil` for undefiend instance variables, which is completely unnecessary. Instead of using `present?`, we could use `defined?` here.

```ruby
def description
  return @description if defined?(@description)
  @description = get_description
end
```

Alternatively, as long as `get_description` doesn’t return `nil` and expect us to memoize it, we could use an “or-write” `||=`

```ruby
def description
  @description ||= get_description
end
```

#### Rendering instance variables that are only set somtimes

It’s common to render an instance variable in an ERB view that you only set on some controllers.

```erb
<div data-favourites="<%= @user_favourites %>"></div>
```

The best solution to this to always set it on all controllers, but set it to `nil` in the cases where you don’t have anything to render. This will prevent you from making a typo in your views.

Alternatively, you could update the view to be explicit about the fact this ivar may not be set.

```erb
<div data-favourites="<%= (@user_favourites ||= nil) %>"></div>
```

Better yet, add a `defined?` check:

```erb
<% if defined?(@user_favourites) %>
  <div data-favourites="<%= @user_favourites %>"></div>
<% end %>
```

## Performance

#### Boot performance

Using Strict Ivars will impact startup performance since it needs to process each Ruby file you require. However, if you are using Bootsnap, the processed RubyVM::InstructionSequences will be cached and you probably won’t notice the incremental cache misses day-to-day.

#### Runtime performance

In my benchmarks on Ruby 3.4 with YJIT, it’s difficult to tell if there is any performance difference with or without the `defined?` guards at runtime. Sometimes it’s about 1% faster with the guards than without. Sometimes the other way around.

On my laptop, a method that returns an instance varible takes about 15ns and a method that checks if an instance varible is defined and then returns it takes about 15ns. All this is to say, I don’t think there will be any measurable runtime performance impact, at least not in Ruby 3.4.

#### Dynamic evals

There is a small additional cost to dynamically evaluating code via `eval`, `class_eval`, `module_eval`, `instance_eval` and `binding.eval`. Dynamic evaluation usually only happens at boot time but it can happen at runtime depending on how you use it.

## Uninstall

Becuase Strict Ivars only ever makes your code safer, you can always back out without anything breaking.

To uninstall Strict Ivars, first remove the require and initialization code from wherever you added it and then remove the gem from your `Gemfile`. If you are using Bootsnap, there’s a good chance it cached some pre-processed code with the instance variable read guards in it. To clear this, you’ll need to delete your bootsnap cache, which should be in `tmp/cache/bootsnap`.
