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
| Appskey & insert          | Create AHK file Insert (base 64 encoding)                        |

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
| Ctrl+Shift+1               | Set Repeat Speed To 250ms                                  |
| Ctrl+Shift+2               | Decrease The Repeat Speed By 50ms                         |
| Ctrl+Shift+3               | Increase The Repeat Speed By 50ms                         |
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

DOMO

AppsKey+Q will parse a domo Ticket page to get "CLIENTID - Firstname Lastname" and put it on the clipboard. This attempts to put focus back in the editor.

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
This is where i learned how to use chrome tab names (no name attribution because no code was taken)

Created by Robert Eding: Rseding91@yahoo.com
Current version 2.6 
https://autohotkey.com/board/topic/64481-include-virtually-any-file-in-a-script-exezipdlletc/page-4

Short description:  Gets the URL of the current (active) browser tab for most modern browsers
https://autohotkey.com/boards/viewtopic.php?t=3702 -- atnbueno



C code for findtext function


```C

/****** the C source code of machine code ******

int __attribute__((__stdcall__)) findstr(int mode
  , unsigned int c, int n, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , char * ss, char * text, int * s1, int * s0
  , int w, int h, int err1, int err0
  , int * rx, int * ry)
{
  int x, y, o=sy*Stride+sx*4, j=Stride-4*sw, i=0;
  int r, g, b, rr, gg, bb, len1, len0, e1, e0;

  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]; g=Bmp[1+o]; b=Bmp[o];
        if ((r-rr)*((r>rr)*2-1)+(g-gg)*((g>gg)*2-1)
          +(b-bb)*((b>bb)*2-1)<=n)
            ss[i]='1';
      }
  }
  else  // Gray Threshold Mode
  {
    c=(c+1)*1000;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]*299+Bmp[1+o]*587+Bmp[o]*114<c)
          ss[i]='1';
  }

  i=len1=len0=0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (text[i++]=='1')
        s1[len1++]=y*sw+x;
      else
        s0[len0++]=y*sw+x;
    }
  }

  w=sw-w+1; h=sh-h+1;
  j=len1>len0 ? len1 : len0;
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      o=y*sw+x; e1=err1; e0=err0;
      for (i=0; i<j; i++)
      {
        if (i<len1 && ss[o+s1[i]]!='1' && (--e1)<0)
          goto NoMatch;
        if (i<len0 && ss[o+s0[i]]!='0' && (--e0)<0)
          goto NoMatch;
      }
      rx[0]=sx+x; ry[0]=sy+y;
      return 1;
      NoMatch:
      continue;
    }
  }
  rx[0]=-1; ry[0]=-1;
  return 0;
}

*/


;================= The End =================

;
```