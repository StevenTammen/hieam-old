<h3>Base Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/base.png">
<h3>Number Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/num.png">
<h3>Shift Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/shift.png">
<h3>Command Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/command.png">
<h3>Window Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/window.png">
<h3>Mouse Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/mouse.png">
<h3>Steno Layer</h3>
<img src = "https://steventammen.com/assets/images/keyboard-layouts/steno.png">
<br/>

I have not yet started the last three layers (and probably won't for a while as they are not as essential), but have the others mostly completed in the form of the autohotkey scripts located in this repository. 

This repository also includes my modified version of [iswitchw](https://github.com/tvjg/iswitchw), a window switching autohotkey application. My version will only pull windows from the current virtual desktop (instead of from all non-hidden windows). I used a very useful [DLL file](https://github.com/Ciantic/VirtualDesktopAccessor) for accessing virtual desktops, courtesy of Jari Pennanen. I also included my slightly tweaked version of [Dual](https://github.com/lydell/dual), an autohotkey library that allows for the creation of dual-role keys and lag-free key combinations, and [hotstrings.ahk](https://autohotkey.com/board/topic/114764-regex-dynamic-hotstrings/), which allows for RegEx based dynamic hotstrings.

I have not worked much on text expansion and commands in expand.ahk, since I want to get up to speed on the layout before sinking in time on these fronts. (Both of these do work, however). I'll probably write a script to automatically create the text expansions from a CSV file at some point, once I start using them more.

The Tab switching, desktop switching, and launching capabilities included in the layout have dependencies on the Chrome extension [Fast Tab Switcher](https://chrome.google.com/webstore/detail/fast-tab-switcher/jkhfenkikopkkpboaipgllclaaehgpjf), the virtual desktop manager [Virtuawin](http://virtuawin.sourceforge.net/), and the app launcher [Launchy](http://www.launchy.net/), respectively. I did not modify any of these applications (or their default activation hotkeys) except for setting the switch to desktop hotkeys in Virtuawin to be Alt + FKey (e.g., Alt + F1 for the first virtual desktop), with the exception of the 4th virtual desktop, which uses Ctrl + F4 instead (for obvious reasons).

Note that all of this is very rough at the moment, with no documentation support. I wanted to get my layout working as quickly as possible, and did not prioritize maintainability and elegance this go around. Since I haven't done any extensive unit testing, there are probably at least a few bugs in the ~4000 lines of code. Any contributions are welcome and appreciated.

Dual, VirtualDesktopAccessor, and iswitchw are all licensed under MIT. This project as a whole is lcensed under GPLv3. Please see [LICENSE.txt](https://github.com/StevenTammen/hieam/blob/master/LICENSE).

<a rel="license", href="http://www.gnu.org/licenses/gpl.html"><img src="http://www.gnu.org/graphics/gplv3-88x31.png", alt="GNU GPLv3 License")></a>
