# AyeVar 🏴‍☠️

Note, this gem is very new and experimental. The API will probably change.

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
