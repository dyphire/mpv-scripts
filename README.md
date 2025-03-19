# mpv-scipts([中文介绍](README_zh.md))

## adevice-list.lua

Interractive audio-device list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

## auto-save-state.lua

Periodically saves progress with write-watch-later-config, and also cleans up the watch later data after the file is finished playing (so playlists may continue at the correct file).

## [clipboard.lua](https://github.com/dyphire/mpv-clipboard/blob/dev/clipboard.lua)

Provides generic low-level clipboard commands for users and script writers.

Requires `powershell` on Windows,`pbcopy`/`pbpaste` on MacOS, `xclip` on X11, and `wl-copy`/`wl-paste` on Wayland.

Modified from: [CogentRedTester/mpv-clipboard](https://github.com/CogentRedTester/mpv-clipboard)

## chapter-list.lua

Interractive chapter-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

Modified from: [CogentRedTester/mpv-scroll-list/chapter-list.lua](https://github.com/CogentRedTester/mpv-scroll-list/blob/master/examples/chapter-list.lua)

## chapter-make-read.lua

Try to load an external `.chp` "chapter sidecar file" when opening a video. (Analog to an external subtitle file like .SRT).

Configuration:

- `video.mp4.chp` is the chapter file for `video.mp4` with the option `basename_with_ext = true` in `chapter-make-read.lua`
- `video.chp` for `video.mp4` with the option `basename_with_ext = false` in `chapter-make-read.lua`
- You could change all parameters of the script by editing your `script-opts/chapter_make_read.conf`, see: [chapter-make-read.lua](chapter-make-read.lua)
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

This script also supports manually load/refresh,marks,edits,remove and creates external chapter files(It can also be used to export the existing chapter information of the playback file). Usage：

Customize the following keybinds in your `input.conf`.

```ini
# Manually load/refresh chapter file
key script-message-to chapter_make_read load_chapter
# Mark chapters
key script-message-to chapter_make_read create_chapter
# Remove current chapter
key script-message-to chapter_make_read remove_chapter
# Edit existing chapter's title
key script-message-to chapter_make_read edit_chapter
# Export chp file
key script-message-to chapter_make_read write_chapter chp
# Export ogm file
key script-message-to chapter_make_read write_chapter ogm
```

- if you want to have the ability to name/rename chapters, the minimum requirement for the mpv version is 0.38.0, or choose to install the [mpv-user-input](https://github.com/CogentRedTester/mpv-user-input)
- Some recommendations

  - another chapters script: [mar04/chapters_for_mpv](https://github.com/mar04/chapters_for_mpv)
  - chapter format conversion tool：https://github.com/fireattack/chapter_converter

## [chapterskip.lua](https://github.com/dyphire/chapterskip/blob/dev/chapterskip.lua)

Automatically skips chapters based on title.

Modified from [po5/chapterskip](https://github.com/po5/chapterskip)

## drcbox.lua

Dynamic Audio Normalizer filter with visual feedback.

Modified from https://gist.github.com/richardpl/0c8011dc23d7ac7b7831b2e6d680114f

## edition-list.lua

Interractive edition-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

- Prints a message on the OSD if editions are found in the file, and temporarily switches the osd-playback-message to the editions-list property when switching. This makes it easier to tell the number and names while navigating editions.

Modified from [CogentRedTester/mpv-scripts/editions-notification.lua](https://github.com/CogentRedTester/mpv-scripts/blob/master/editions-notification.lua)

## history-bookmark.lua

This script helps you to create a history file `.mpv.history` in the specified path. The next time you want to continue to watch it, you can open any videos in the folder. The script will lead you to the video played last time.

Modified from [yuukidach/history-bookmark.lua](https://github.com/yuukidach/mpv-scripts/blob/master/history_bookmark.lua)

## mpv-animated.lua

Creates high quality animated webp/gif using mpv hotkeys. Requires that FFmpeg be installed.

Modified from [DonCanjas/mpv-webp-generator](https://github.com/DonCanjas/mpv-webp-generator)

## mpv-torrserver.lua

sends torrent info to [TorrServer](https://github.com/YouROK/TorrServer) and gets playlist. Supports torrent files and magnet links. Requires curl and [TorrServer](https://github.com/YouROK/TorrServer).

### Usage

Drag & Drop torrent into mpv, or:

```sh
mpv <magent link or torrent file>
```

Modified from [kritma/mpv-torrserver](https://github.com/kritma/mpv-torrserver)

## open_dialog.lua

Load folder/files/iso/clipboard (support url)/other subtitles/other audio tracks/other video tracks. (Windows)

**Note**: Windows 10/11 users are recommended to use it with PowerShell 7. Advantages: better performance, more modern dialog styles.

- Official Installation Command: `winget install Microsoft.PowerShell`

Inspiration from [rossy/mpv-open-file-dialog](https://github.com/rossy/mpv-open-file-dialog), [tsl0922/dialog.lua](https://github.com/tsl0922/mpv-menu-plugin/blob/main/lua/dialog.lua)

## [playlistmanager.lua](https://github.com/dyphire/mpv-playlistmanager)

Mpv lua script to create and manage playlists

Modified from [jonniek/mpv-playlistmanager](https://github.com/jonniek/mpv-playlistmanager)

## [recent.lua](https://github.com/dyphire/recent)

Logs played files to a history log file with an interactive 'recently played' menu that reads from the log. Allows for automatic or manual logging if you want a file bookmark menu instead.

Modified from [hacel/recent](https://github.com/hacel/recent)

## skiptosilence.lua

This script skips to the next silence in the file. The intended use for this is to skip until the end of an opening or ending sequence, at which point there's often a short period of silence.

Modified from [detuur-mpv-scripts/skiptosilence.lua](https://github.com/Eisa01/detuur-mpv-scripts/blob/master/skiptosilence.lua)

## slicing_copy.lua

This script is for mpv to cut fragments of the video.. Requires that FFmpeg be installed.

Modified from [snylonue/mpv_slicing_copy](https://github.com/snylonue/mpv_slicing_copy)

## sponsorblock_minimal.lua

This script skip/mute sponsored segments of YouTube and bilibili videos

using data from https://github.com/ajayyy/SponsorBlock and https://github.com/hanydd/BilibiliSponsorBlock

Modified from [jouni/mpv_sponsorblock_minimal](https://codeberg.org/jouni/mpv_sponsorblock_minimal)

## sub_export.lua

Export the internal subtitles of the playback file. Requires that FFmpeg be installed.

The script support subtitles in srt, ass, and sup formats.

Modified from [kelciour/mpv-scripts/sub-export.lua](https://github.com/kelciour/mpv-scripts/blob/master/sub-export.lua)

## [sub-fastwhisper.lua](https://github.com/dyphire/mpv-sub-fastwhisper)

Generate srt subtitles through voice transcription using faster-whisper

## track-list.lua

Interractive track-list menu on OSD. Requires that [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list) be installed.

## trackselect.lua

Automatically select your preferred tracks based on title, because --alang isn't smart enough.

Modified from [po5/trackselect](https://github.com/po5/trackselect)

## [trakt-scrobble.lua](https://github.com/dyphire/trakt-scrobble)

A MPV script that checks in your movies and shows with Trakt.tv

Modified from [LiTO773/trakt-mpv](https://github.com/LiTO773/trakt-mpv)

## [uosc.lua](https://github.com/dyphire/uosc)

Feature-rich minimalist proximity-based UI for [MPV player](https://mpv.io/).

Modified from [tomasklaen/uosc](https://github.com/tomasklaen/uosc)
