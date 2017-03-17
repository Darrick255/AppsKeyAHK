# AppsKeyAHK
Personal Auto Hotkey Script To Help With Daily Office Work
This means it is very Rough around the edges.

Features Include
 - Clipboard History
 - Window Hiding
 - Text Manipulation
    - Change Case
    - Regex Replace Selection
 - Window Management
    - Temporarily Hide Windows
    - Make Windows Transparent
    - Windows Always On Top
    - Drag Window From Anywhere
 - Media Keys
    - Play/pause/skip
    - Volume Control

Appskey & ~ : Help Menu
---------
| Key                  | Action                                |
| -------------------- | ------------------------------------- |
| AppsKey & ~          | This help menu.                       |
| Appskey & a          | Always on top on                      |
| Appskey & Shift & A  | Always on top off                     |
| Appskey & b          | Powermanager switch off display       |
| Appskey & t          | Make 50`% transparent                 |
| Appskey & Shift & T  | Make fully Visible                    |
| Appskey & v          | Paste clipboard as plain text         |
| Appskey & w          | Wrap tect at input value(70)          |
| Appskey & x          | Power state menu                      |
| Appskey & /          | RegEx replace                         |
| Appskey & ,          | input tag and attributes. HTML Format |
| Appskey & [          | input tag and attributes. BB format   |
| Appskey & .          | Hide window                           |
| Appskey & Shift & .  | Reveal Windows Hidden                 |
| Appskey & F4         | Force Close Window With Prompt        |
| Appskey & Shift & F4 | Force Close Without Prompt            |
| Appskey & r          | Reload Script.                        |

Left Alt & Left Shift & Tilde: Restore All Hidden Windows

LM: allows click draging of window without clicking on tile bar

# Media Keys
| AppsKey & | Action          |
| --------- | --------------- |
| UP        | Volume up.      |
| DOWN      | Volume Down.    |
| RIGHT     | Next Track.     |
| LEFT      | Previous Track. |
| SPACE     | Play/Pause.     |

# ClipBoard Stuff
| Keys &                     | Action                                                    |
| -------------------------- | --------------------------------------------------------- |
| Ctrl+C, Ctrl+X             | Add To Clipboard History                                  |
| Ctrl+Shift+C, Ctrl+Shift+X | Move Though Clipboard History                             |
| Ctrl+Shift+5               | Clear History                                             |
| Ctrl+Shift+Z               | Load Highlighted Text Into Clipboard History Line By Line |
| Ctrl+Shift+V               | Paste And Move To Next Item Follows Repeat Speed          |
| Ctrl+Shift+R               | Paste Clipboard(and do {actions} ) And Go Forward One     |
| Ctrl+Shift+1               | Set Repeat Speed To 50ms                                  |
| Ctrl+Shift+2               | Decrease The Repeat Speed By 25ms                         |
| Ctrl+Shift+3               | Increase The Repeat Speed By 25ms                         |
| Ctrl+Shift+4               | Set Repeat Speed To 200ms                                 |
| Ctrl+Shift+5               | Clear History                                             |


>actions{} https://autohotkey.com/docs/commands/Send.htm

| Code | Key/meaning                      |
| ---- | -------------------------------- |
| #    | Win (Windows logo key).          |
| !    | Alt                              |
| ^    | Control                          |
| +    | Shift                            |
| <    | Use the left key of the pair.    |
| >    | Use the right key of the pair.   |
| &    | between two keys to combine them |


There Have Also Been some addition for my own Specific work environment
---
DOMO

Ctrl+Shift+Q will parse a domo Ticket page to get "CLIENTID - Firstname Lastname"

Credits

https://autohotkey.com/board/topic/25393-appskeys-a-suite-of-simple-utility-hotkeys/
ManaUser For the original appskey script

https://autohotkey.com/docs/scripts/EasyWindowDrag.htm
for window draging code

https://autohotkey.com/docs/scripts/VolumeOSD.htm
Volume On-Screen-Display (OSD) -- by Rajat

https://autohotkey.com/board/topic/35566-rapidhotkey/
HotKeyIt -- RapidHotkey()

https://autohotkey.com/board/topic/76062-ahk-l-how-to-get-callstack-solution/
fragman -- Get stack information 

https://autohotkey.com/boards/viewtopic.php?f=6&t=53
tidbit - String Things - Common String & Array Functions

http://stackoverflow.com/questions/19350814/identifying-a-chrome-webpage
https://github.com/ilirb/ahk-scripts/blob/master/executable/source/GoogleMusicRemote.ahk
This is where i learned how to use chrome tab names