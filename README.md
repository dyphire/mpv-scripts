# mpv-scipts([中文介绍](README_zh.md))

## adevice-list.lua

Interractive audio-device list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

## chapter-list.lua

Interractive chapter-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

Modified from: [CogentRedTester/mpv-scroll-list/chapter-list.lua](https://github.com/CogentRedTester/mpv-scroll-list/blob/master/examples/chapter-list.lua)

## chapter-make-read.lua

Automatically read an load the namesake external chapter file with extension of `.chp`. 

Example: `video.mp4.chp` to `video.mp4`.

- You could change all parameters of script by editing your `script-opts/chapter_make_read.conf`. see [chapter-make-read.lua](chapter-make-read.lua) for details.
- Timestamps for external chapter files should use the 12-bit format of `hh:mm:ss.sss`.
- The external chapter files encoding should be UTF-8 and the linebreak should be Unix(LF).

The script supports external chapter file content in the following formats:

```
00:00:00.000 A part
00:00:40.312 OP
00:02:00.873 B part
00:10:44.269 C part
00:22:40.146 ED
```

```
00:00:00.000
00:00:40.312
00:02:00.873
00:10:44.269
00:22:40.146
```

```
0:00:00 A part
0:00:40 OP
0:02:00 B part
0:10:44 C part
0:22:40 ED
```

```
0:00:00.000,Title1
0:17:02.148,Title2
0:28:10.114,Title3
```
 OGM format (`ogm`)

```
CHAPTER01=00:00:00.000
CHAPTER01NAME=Intro
CHAPTER02=00:02:30.000
CHAPTER02NAME=Baby prepares to rock
CHAPTER03=00:02:42.300
CHAPTER03NAME=Baby rocks the house
```
MediaInfo format (`mediainfo`)

```
Menu
00:00:00.000                : en:Contours
00:02:49.624                : en:From the Sea
00:08:41.374                : en:Bread and Wine
00:12:18.041                : en:Faceless
```

This script also supports marks,edits,remove and creates external chapter files(It can also be used to export the existing chapter information of the playback file). Usage：

Customize the following keybinds in your `input.conf`.

```ini
# Mark chapters
key script-message-to chapter_make_read create_chapter
# Remove current chapter
key script-message-to chapter_make_read remove_chapter
# Edit existing chapter's title
key script-message-to chapter_make_read edit_chapter
# Export chp file
key script-message-to chapter_make_read write_chapter
# Export xml file
key script-message-to chapter_make_read write_chapter_xml
```
- if you want to have the ability to name/rename chapters, you'll need to install
  <https://github.com/CogentRedTester/mpv-user-input>

- Some recommendations
   -  another chapters script: [mar04/chapters_for_mpv](https://github.com/mar04/chapters_for_mpv)
   -  chapter format conversion tool：https://github.com/fireattack/chapter_converter

## [chapterskip.lua](https://github.com/dyphire/chapterskip/blob/dev/chapterskip.lua)

Automatically skips chapters based on title.

Modified from [po5/chapterskip](https://github.com/po5/chapterskip/blob/master/chapterskip.lua)

## drcbox.lua

Dynamic Audio Normalizer filter with visual feedback.

Modified from https://gist.github.com/richardpl/0c8011dc23d7ac7b7831b2e6d680114f

## edition-list.lua

Interractive edition-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.
- Prints a message on the OSD if editions are found in the file, and temporarily switches the osd-playback-message to the editions-list property when switching. This makes it easier to tell the number and names while navigating editions.

Modified from [CogentRedTester/mpv-scripts/editions-notification.lua](https://github.com/CogentRedTester/mpv-scripts/blob/master/editions-notification.lua)

## fix-avsync.lua

Fixed video freezing caused when switching audio tracks.

Ref: [MPV video stutters when certain audio filter enabled · Issue #9591 · mpv-player/mpv ](https://github.com/mpv-player/mpv/issues/9591)

## [history-bookmark.lua](https://github.com/dyphire/yuukidach-mpv-scripts/blob/master/history-bookmark.lua)

This script helps you to create a history file `.mpv.history` in the specified path. The next time you want to continue to watch it, you can open any videos in the folder. The script will lead you to the video played last time.

Modified from [yuukidach/history-bookmark.lua](https://github.com/yuukidach/mpv-scripts/blob/master/history-bookmark.lua)

## mediaInfo.lua

Use `MediaInfo` to get media info and print it on OSD.

And shared the `hdr-format` property by [shared_script_properties](https://mpv.io/manual/master/#command-interface-shared-script-properties), available for conditional profiles.

Modified from [stax76/misc.lua ](https://github.com/stax76/mpv-scripts/blob/main/misc.lua)

## mpv-animated.lua

Creates high quality animated webp/gif using mpv hotkeys. Requires that FFmpeg be installed. (Windows)

Modified from [DonCanjas/mpv-webp-generator](https://github.com/DonCanjas/mpv-webp-generator)

## open_dialog.lua

Load file/url/other subtitles/other audio tracks/advanced subtitle filter. (Windows)

Modified from [rossy/mpv-open-file-dialog](https://github.com/rossy/mpv-open-file-dialog)

## [playlistmanager.lua](https://github.com/dyphire/mpv-playlistmanager)

Mpv lua script to create and manage playlists

Modified from [jonniek/mpv-playlistmanager](https://github.com/jonniek/mpv-playlistmanager)

## sub_export.lua

Export the internal subtitles of the playback file. Requires that FFmpeg be installed.

The script support subtitles in srt, ass, and sup formats.

Modified from [kelciour/mpv-scripts/sub-export.lua](https://github.com/kelciour/mpv-scripts/blob/master/sub-export.lua)

## track-list.lua

Interractive track-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

## [uosc.lua](https://github.com/dyphire/uosc)

Feature-rich minimalist proximity-based UI for [MPV player](https://mpv.io/).

Modified from [tomasklaen/uosc](https://github.com/tomasklaen/uosc)
