# hx-ansi
Fork of hx.strings.ansi (in Haxe) and very modest additions to that (StringAnsi, StringExt)

The Ansi classes are simple declarations coming from the much bigger https://github.com/vegardit/haxe-strings (we in fact extracted and renamed its hx.strings.ansi package). For these classes the copyright belong to Sebastian Thomschke, Vegard IT GmbH (Apache license).

Additions are really straightforward:

1. **StringExt** contains vain methods such as `"sun,moon,earth".until(",")`, `"Mister:Bean".after(":")`, `"path/to/file.ext".stripExt(".ext")`, `"Isolated".surround("[]")`, `"My title".center(30)`.
2. **StringAnsi** adds many static functions for extensions like `"today".blue().blink() + "the ".faint() + "sun".yellow().bold() + "shines".bold()`.

I don't especially encourage you to use this, as there exists 2 choices already: a more popular `ansi` haxelib, and the above https://github.com/vegardit/haxe-strings.
