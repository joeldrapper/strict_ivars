# AyeVar 🏴‍☠️

Avast ye, this gem be fresh off th’ plunderin’ an’ experimental as a new recruit, me hearties! Th’ API be shiftin’ like th’ treacherous seas beneath yer barnacled hull.

## What does it do?

It keelhauls them scurvy undefined instance variables by transformin’ yer code as it loads into th’ hold, savvy? Davy Jones ’imself would approve!

## Setup

Add this precious booty to yer gemfile, shiver me timbers!

```ruby
gem "aye_var", require: false
```

Then be requirin’ an’ initializin’ it in yer galleon as early as ye can hoist sail, ye scallywag! If ye be usin’ Bootsnap, place it right after, or by the powers, ye’ll be swimmin’ with th’ fishes!

```ruby
require "aye_var"

AyeVar.init(include: ["#{Dir.pwd}/**/*"])
```

Ye can pass an array o’ globs to `include:` an’ `exclude:`, or I’ll feed ye to th’ kraken, ye mangy bilge-suckin’ swab!
