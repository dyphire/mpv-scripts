# mpv-scipts

## adevice-list.lua

高级 OSD 音频设备菜单，依赖 [scroll-list.lua](https://github.com/dyphire/mpv-scroll-list)

## copy_subortime.lua

复制当前字幕内容或当前时间（Windows）

修改自 https://github.com/linguisticmind/mpv-scripts

## chapter_make_read.lua

实现自动读取并加载视频文件同目录或指定的子目录（默认：`chapters`）下的同名扩展的外部章节文件，默认标识和扩展名：`_chapter.chp`

- 子目录和标识扩展名的更改可在`script-opts`下的脚本同名配置文件`chapter_make_read.conf`中设置

外部章节文件的时间戳尽可能使用`hh:mm:ss.sss`的12位格式

文件编码应为 UTF-8，换行符为 Unix(LF)

以下几种外部章节文件内容的写法均被该脚本支持

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

该脚本同时支持标记并创建外部章节文件（也可用于导出已有的章节信息），用法如下：

在 mpv 的 input.conf 中绑定以下功能键位

```ini
# 标记章节时间
key script-message-to chapter_make_read create_chapter
# 创建 mpv 可读的外部章节文件
key script-message-to chapter_make_read write_chapter
# 创建 xml 格式的外部章节文件
key script-message-to chapter_make_read write_chapter_xml
```

推荐搭配此工具使用：https://github.com/fireattack/chapter_converter

## drcbox.lua

动态调节各通道音增益的 dynnorm 滤镜菜单脚本

修改自 https://gist.github.com/richardpl/0c8011dc23d7ac7b7831b2e6d680114f

## fix-avsync.lua

修复存在音频过滤器时切换音轨和调整播放速度带来的视频冻结卡顿的问题

## open_dialog.lua

快捷键载入文件/网址/其他字幕或音轨/高级次字幕

## sub_export.lua

导出当前内封字幕，依赖 ffmpeg，脚本支持 srt、ass 和 sup 格式的字幕

修改自 [kelciour/mpv-scripts/sub-export.lua](https://github.com/kelciour/mpv-scripts/blob/master/sub-export.lua)

## ytdl_hook_plus.lua

ytdl_hook.lua 的增强脚本，使用该脚本需在 mpv.conf 中写入参数`ytdl=no`

脚本来自 [zhongfly/ytdl_hook_plus.lua](https://gist.github.com/zhongfly/e95fa433ca912380f9f61e0910146d7e/0f46340621415ae93a91a7f3eb60d013c5bdf542#file-ytdl_hook_plus-lua)

## 更多 mpv 实用脚本请移步 [dyphire/mpv-config/scripts](https://github.com/dyphire/mpv-config/tree/master/scripts)
