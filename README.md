## TODOs (mirrored from the top of remap.ahk)

```
;    TODO: get normal text briefs working with terminating characters. Dynamic regex hotstrings with subroutines?
;    TODO: get normal text expansion with {Expd} working. E.g., u{Expd} --> you, instantly.
;    TODO: get Alt-F4 put in place for \-prefixed Esc
;    TODO: make \ into a dual role key with F21 for sequences of non-autospaced characters. Figure out how to deal with downKey and upKey differences 
;    TODO: make keys after a #@`~ on F16 layer act as if F17 was down, not F16.

;    TODO: window move/resize command layer
;    TODO: mouse layer: t-warp, warp, fast/slow
;    TODO: construct layer. Start off with Org mode and code constructs like while, switch, etc.
;    TODO: put remap, expand, and window scripts in windows startup sequence

;    TODO: Figure out why F21 Down would have to be included in both remap and expand, not just remap, to start non-autospaced. Initial key states across scripts?
;    TODO: Figure out why WinActivate on chrome class is necessary rather than using WinGetClass etc. (For script-internal window focusing)
;			WinActivate, ahk_class Chrome_WidgetWin_1
```

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

I have not yet finished the last three layers (and probably won't for a while as they are not as essential), but have the others mostly completed in the form of the autohotkey scripts located in this repository.

Please note that the keybindings are currently assuming a specific keymap. I am temporarily using a Kinesis Advantage 2 (until I get around to buying or assembling a board with a hackable microcontroller), so the assumed default map is based on the on-board firmware remapped layout that I have on my Kinesis. Here's a picture:

<br/><img src = "https://steventammen.com/assets/images/keyboard-layouts/kinesis.png"><br/><br/>

This repository also includes my modified version of [iswitchw](https://github.com/tvjg/iswitchw), a window switching autohotkey application. My version will only pull windows from the current virtual desktop (instead of from all non-hidden windows). I used a very useful [DLL file](https://github.com/Ciantic/VirtualDesktopAccessor) for accessing virtual desktops, courtesy of Jari Pennanen. I also included my slightly tweaked version of [Dual](https://github.com/lydell/dual), an autohotkey library that allows for the creation of dual-role keys and lag-free key combinations, and [hotstrings.ahk](https://autohotkey.com/board/topic/114764-regex-dynamic-hotstrings/), which allows for RegEx based dynamic hotstrings.

Character-terminated hotstrings are currently non-functional due to the complications that layers introduce into the key history. It may be possible to overcome the complications through some dynamic regex hotstrings and cleverness, but having firmware layers abstracted out of AutoHotkey would make the process much cleaner. This is not a big priority for me because I'm learning stenography, but I plan to get it working eventually. Commands (e.g., \sleep{Expd}) and named entities (e.g., \pi{Expd}) are fully functional.

The Tab switching, desktop switching, and launching capabilities included in the layout have dependencies on the Chrome extension [Fast Tab Switcher](https://chrome.google.com/webstore/detail/fast-tab-switcher/jkhfenkikopkkpboaipgllclaaehgpjf), the virtual desktop manager [Virtuawin](http://virtuawin.sourceforge.net/), and the app launcher [Launchy](http://www.launchy.net/), respectively. I did not modify any of these applications (or their default activation hotkeys) except for setting the switch to desktop hotkeys in Virtuawin to be Alt + FKey (e.g., Alt + F1 for the first virtual desktop), with the exception of the 4th virtual desktop, which uses Ctrl + F4 instead (for obvious reasons).

Note that all of this is very rough at the moment, with no documentation support. I wanted to get my layout working as quickly as possible, and did not prioritize maintainability and elegance this go around. Since I haven't done any extensive unit testing, there are probably at least a few bugs in the ~4000 lines of code. Any contributions are welcome and appreciated.

My current modifications to make terminal Vim/Emacs work with the layout switch around some commands to get the cursor keys in the T-shaped formation of tcsr. All the changes have mnemonics, albeit different ones than vanilla Vim.

Here's the code to put in .vimrc:

```
nnoremap <C-h> X
nnoremap <Del> x

nnoremap t h
nnoremap T H

nnoremap s j

nnoremap r l
nnoremap R L

nnoremap c k

nnoremap h d
nnoremap H D
nnoremap hh dd

nnoremap k s

nnoremap l r
nnoremap L R

nnoremap d c
nnoremap D C
nnoremap dd cc

nnoremap x t
nnoremap X T
```

And for those who use Spacemacs (or some other evil-based keymap) in Emacs:

```
(global-set-key (kbd "C-h") 'delete-backward-char)
(define-key evil-normal-state-map (kbd "C-h") 'evil-delete-backward-char)
(define-key evil-normal-state-map [deletechar] 'evil-delete-char)

(define-key evil-normal-state-map "t" 'evil-backward-char)
(define-key evil-normal-state-map "T" 'evil-window-top)

(define-key evil-normal-state-map "s" 'evil-next-line)

(define-key evil-normal-state-map "r" 'evil-forward-char)
(define-key evil-normal-state-map "R" 'evil-window-bottom)

(define-key evil-normal-state-map "c" 'evil-previous-line)

(define-key evil-normal-state-map "h" 'evil-delete)
(define-key evil-normal-state-map "H" 'evil-delete-line)

(define-key evil-normal-state-map "k" 'evil-substitute)

(define-key evil-normal-state-map "l" 'evil-replace)
(define-key evil-normal-state-map "L" 'evil-replace-state)

(define-key evil-normal-state-map "d" 'evil-change)
(define-key evil-normal-state-map "D" 'evil-change-line)

(define-key evil-normal-state-map "x" 'evil-find-char-to)
(define-key evil-normal-state-map "X" 'evil-find-char-to-backward)
```

The mnemonics below make sense to me, which is what is important. You may want to do your own tinkering if you don't like them. You can use [this page](https://vimhelp.appspot.com/index.txt.html) to make sure you aren't losing commands in your remapping, and [this page](https://github.com/emacsmirror/evil/blob/master/evil-maps.el) to identify evil-functions for vim behavior. I haven't looked much into global command or bracket command conflicts caused by these remappings, but I'll handle them later (I only noticed a couple conflicts). I'm still too new to Vim to really worry about much other than straight normal mode.

Mnemonics:

- H for "harvest" = cut Nmove text. Replaces d/D/dd.
- D for "delete" = delete Nmove text and enter insert mode. You don't delete text you want to paste, you *harvest* it. Replaces c/C/cc.
- K for "kill" = delete character under cursor and enter insert mode. You delete text but kill characters. (This still gives me a chuckle every time... I guess I have a strange sense of humor). Replaces s. S as a command is lost, since I just use dd (i.e., cc) instead.
- Backspace/Delete take over X/x, respectively. I never understood why x was necessary as a separate command.
- X for "up/back to but excluding" = till/to. Replaces t/T.
- L for "layer" = overwrite N characters or toggle overwrite mode. Replaces r/R.

Note that J and K retain their special meanings. I'll probably remap j to something else eventually once I have a better idea what would be useful to put there.

Note that Dual, VirtualDesktopAccessor, and iswitchw are all licensed under MIT. This project as a whole is licensed under GPLv3. Please see [LICENSE.txt](https://github.com/StevenTammen/hieam/blob/master/LICENSE).

<br/>
<a rel="license", href="http://www.gnu.org/licenses/gpl.html"><img src="http://www.gnu.org/graphics/gplv3-88x31.png", alt="GNU GPLv3 License")></a>
