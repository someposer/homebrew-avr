Homebrew-avr
============
This repository contains the Atmel version of the GNU AVR toolchain as formulae for [Homebrew](https://github.com/mxcl/homebrew).

AVR is a popular family of microcontrollers, used for example in the [Arduino](http://arduino.cc) project.

This version was forked from [larsimmisch/homebrew-avr](https://github.com/larsimmisch/homebrew-avr), and modified to use the [Atmel 3.4.3.1072 sources](http://distribute.atmel.no/tools/opensource/Atmel-AVR-GNU-Toolchain/3.4.3/)

Installing Homebrew-avr Formulae
--------------------------------
To get the avr toolchain tap `brew tap someposer/homebrew-avr` and then
`brew install <formula>`.

To install the entire AVR toolchain, do:
`brew install avr-libc`

This will pull in the prerequisites avr-binutils and avr-gcc.

You can also install via URL:

```
brew install https://raw.github.com/someposer/homebrew-avr/master/<formula>.rb
```

Docs
----
`brew help`, `man brew`, or the Homebrew [wiki][].

[wiki]:http://wiki.github.com/mxcl/homebrew
[homebrew-dupes]:https://github.com/Homebrew/homebrew-dupes
[homebrew-versions]:https://github.com/Homebrew/homebrew-versions
