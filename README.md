# ansistral

Personal lib, unrecommended to use.  These classes are partly taken from hx.strings.ansi (in Haxe) and the others are very modest additions to that (StringAnsi, StringExt). Everything sits in a stypid `ansistral` package. 

The purpose of the lib is for me to not have to use the very big hx.strings.ansi package, and also to develop light String methods (mostly around the need for Ansi).

Additions are really straightforward and you won't need this lib unless you want some features dealing with ansi length or center:

1. **StringExt** contains vain methods such as `"sun,moon,earth".until(",")`, `"Mister:Bean".after(":")`, `"path/to/file.ext".stripExt(".ext")`, `"Isolated".surround("[]")`, `"My title".center(30)`.
2. **StringAnsi** adds many static functions for extensions like `"today".blue().blink() + "the ".faint() + "sun".yellow().bold() + "shines".bold()`.


# Disclaimer and copyright

The Ansi classes are simple declarations coming from the much bigger https://github.com/vegardit/haxe-strings (we extracted the 4 small classes from its package  hx.strings.ansi package). For these classes the copyright belong to Sebastian Thomschke, Vegard IT GmbH (Apache license).

The others are from me, and placed in the same license to simplify things.

I don't especially encourage you to use this lib, as there exists 2 choices already: a more popular `ansi` haxelib, and the above also very popular https://github.com/vegardit/haxe-strings from which most classes are copied. 

In the end, I will probably choose to use either one as a dependency and this package will merely retain its two classes StringExt and StringAnsi. 

