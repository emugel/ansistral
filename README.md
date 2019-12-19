# ansistral

Personal lib, still unrecommended to use for now. 

Part of this lib use small defs taken from `hx.strings.ansi`, and add 3 new extension classes:

* StringExt :: contains unessential methods such as `"sun,moon,earth".until(",")`, `"Mister:Bean".after(":")`, `"path/to/file.ext".stripExt(".ext")`, `"Isolated".surround("[]")`, `"My title".center(30)`.
* StringAnsi :: adds many static functions for extensions like `"today".blue().blink() + "the ".faint() + "sun".yellow().bold() + "shines".bold()`,
* Screen ::  detects terminal size on sys targets.


# Disclaimer and copyright

The Ansi classes are simple declarations coming from the much bigger https://github.com/vegardit/haxe-strings (we extracted the 4 small classes from its package  hx.strings.ansi package). For these classes the copyright belong to Sebastian Thomschke, Vegard IT GmbH (Apache license).

The others are from me, and placed in the same license to simplify things.

I don't especially encourage you to use this lib, as there exists 2 choices already: a more popular `ansi` haxelib, and the above also very popular https://github.com/vegardit/haxe-strings from which most classes are copied. 

In the end, I will probably choose to use either one as a dependency and this package will merely retain its two classes StringExt and StringAnsi. 

