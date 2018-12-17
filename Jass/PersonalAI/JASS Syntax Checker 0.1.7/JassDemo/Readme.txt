================================================================
| Demo Jass Syntax Checker (0.1.7)                             |
----------------------------------------------------------------
| Author:  Jeff Pang <jp@magnus99.dhs.org>                     |
| Website: http://jass.sourceforge.net                         |
================================================================

This is a simple demo for checking the syntax of Warcraft III
JASS scripts (both for the original ROC and expansion TFT).

To use this demo you need a Java Runtime Environment installed,
and should be running Windows or Mac OS X. Mac users will
already have a JRE installed, Windows users may also, but can
get one from:

http://java.sun.com/j2se/1.3/download.html

For Mac OS X Users:

1) Enter this directory
2) Double click on 'JassDemo'

For Windows Users:

1) Enter this directory
2) Double click on 'JassDemo.exe'


If you want to use custom common.ai or Blizzard.j files, then
place your custom replacements in the Scripts/ directory.
WARNING: The files will "load" even if they have syntax errors
in them. In some cases, the parser will be able to load enough
to ignore the errors, otherwise it will just silently fail. You
should make sure your custom files pass the checker with the
Library option checked.

For additional help with this program and JASS see:

http://jass.sourceforge.net/help.shtml
