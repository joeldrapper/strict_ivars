# AyeVar 🏴‍☠️

Note, this gem is very new and experimental. The API will probably change.

## What does it do?

It prevents you from using undefined instance variables by transforming your code as it is loaded.

Instance variables must be defined in your object’s initializer (even if they are initially set to `nil`). Only then can they be accessed in the rest of the code.

## Setup

Add this gem to your gemfile.

```ruby
gem "aye_var", require: false
```

Then require and initialize it in your app as early as possible. If you’re using Bootsnap, it should be right after Bootsnap.

```ruby
require "aye_var"

AyeVar.init(include: ["#{Dir.pwd}/**/*"])
```

You can pass in an array of globs to `include:` and `exclude:`.
