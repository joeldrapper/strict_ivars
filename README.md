# Strict Ivars

Strict Ivars is a tiny pre-processor for Ruby that guards your instance variable reads, ensuring the instance variable is actually defined. This helps catch typos nice and early. It‘s especially good when used with [Literal](https://literal.fun).

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

The real guard is a little uglier than this. It uses `::Kernel.raise` so it’s compatible with `BasicObject`. It also raises a `StrictIvars::NameError` with a helpful message mentioning the name of the instance variable, and that inherits from `NameError`, allowing you to rescue either `NameError` or `StrictIvars::NameError`.

**When you check defined already**

Within the same context (e.g. class definition, module definition, block, method), if you check `defined?`, Strict Ivars will not add a guard to reads of the checked instance variable.

```ruby
if defined?(@foo)
  @foo
end
```

This applies even if the read is not in one of the conditional’s branches since you’ve indicated local awareness of the potential for this instance variable not being defined.

```ruby
if defined?(@foo)
  # anything
end

@foo
```

**Writes:**

Strict Ivars doesn’t apply to writes, since these are considered the authoritative source of the instance variable definitions.

```ruby
@foo = 1
```

**Or-writes:**

This is considered a definition and not guarded.

```ruby
@foo ||= 1
```

**And-writes:**

This is considered a definition and not guarded.

```ruby
@foo &&= 1
```

## Setup

Install the gem by adding it to your `Gemfile` and running `bundle install`.

You may want to set it to `require: false` here because you should require it manually at precisely the right moment.

```ruby
gem "strict_ivars", require: false
```

Now the gem is installed, you should require and initialize the gem as early as possible in your boot process. Ideally, this should be right after Bootsnap is set up. In Rails, this will be in your `boot.rb` file.

```ruby
require "strict_ivars"

StrictIvars.init(include: ["#{Dir.pwd}/**/*"], exclude: ["#{Dir.pwd}/vendor/**/*"])
```

You can pass an array of globs to `include:` and `exclude:`.

## Compatibility

Because Strict Ivars only transforms the source code that matches your include paths and becuase the check happens at runtime, it’s completely compatible with the rest of the Ruby ecosystem.

#### For apps

Strict Ivars is really designed for apps, where you control the boot process and you want some extra safety in the code you and your team writes.

#### For libraries

You could use Strict Ivars as a dev dependency in your gem’s test suite, but I don’t recommend initializing Strict Ivars in a library directly.

## Performance

#### Startup performance

Using Strict Ivars will impact startup performance since it needs to process each Ruby file you require. However, if you are using Bootsnap, the processed RubyVM::InstructionSequences will be cached and you probably won’t notice the incremental cache misses day-to-day.

#### Runtime performance

In my benchmarks on Ruby 3.4 with YJIT, it’s difficult to tell if there is any performance difference with or without the `defined?` guards at runtime. Sometimes it’s about 1% faster with the guards than without. Sometimes the other way around.

On my laptop, a method that returns an instance varible takes about 15ns and a method that checks if an instance varible is defined and then returns it takes about 15ns.

All this is to say, I don’t think there will be any measurable runtime performance impact.

## Uninstall

Becuase Strict Ivars only ever makes your code safer, you can always back out without anything breaking.

To uninstall Strict Ivars, first remove the require and initialization code from wherever you added it and then remove the gem from your `Gemfile`. If you were using Bootsnap, there’s a good chance it cached some pre-processed code with the instance variable read guards in it. To clear this, you’ll need to delete your bootsnap cache, which should be in `tmp/cache/bootsnap`.
