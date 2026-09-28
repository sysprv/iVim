# iVim

iVim is a project that brings the vim editor to the iOS system.

## About this fork

This fork is some quick cleanup for my own use and taste, done with the
help of an LLM, not a maintained continuation of iVim. I wanted iVim
working properly on iOS 27: the vim window wasn't staying above the
keyboard, so the statusline and command line were hidden. iVim's
extended keyboard and a real `gui_running` vim are still the best vim
setup I've found on iOS; Blink Shell, a-Shell and the like don't really
work for me.

What changed: the vim window stays between the top of the screen and the
keyboard, the cursor no longer flickers with `blinkon0`, `:q` quits
again, `:terminal`/ivish and external commands build against the
current upstream ios_system (see "Building this fork" below) and get
vim's environment for commands, and vim itself is updated from 8.1 to
9.2. It's built for my own use (own bundle ids, no App Group or iCloud,
distributed to myself via TestFlight); Python isn't included yet.

Type `:help ios` in iVim for more detailed information.

## Features

### Font management

Besides some system and embedded monospace fonts, iVim allows users to import and use their own custom fonts.
Also, iVim provides commands for more intuitive and efficient font management.

### Extended keyboard

By introducing compact buttons, iVim covers as many keys as possible in its extended keyboard, so that you can input symbols without switching among key groups. Moreover, you can customize it to meet your own special needs.

### Multistage language input

iVim adds support to multistage input languages such as Chinese or Japanese. 

### Sharing

Through sharing, iVim makes its editing power available to more apps.
Via the share extension, iVim can import text or text files from, or export to other apps.
Via the document picker, you can also import or edit files or directories in iCloud Drive or documents providers, without leaving iVim.

### External hardware keyboard

iVim supports external hardware keyboards well, just connect your favorite one to the device and start typing. With the native modifier keys mapping option from the system, you can even make the "caps lock" key act both as "ctrl" and "esc" in iOS 13.4 and above.

### Auto restore

After an app termination, iVim restores the last editing session automatically on launch. So you don't have to worry about data losing any more. And you can disable it in Settings.app if you prefer the old way.

### External commands

iVim includes some useful external commands that you are familiar with and integrates powerful scripting languages such as Python and Lua. With +terminal feature enabled and a simple shell named "ivish" included, you can run the commands in terminal windows like on a computer.

### Plugins Management

iVim provides a plugins manager, "iplug", for you to install and manage plugins easily.

## How to install it

### App Store
iVim is now on [App Store](https://itunes.apple.com/us/app/ivim/id1266544660?mt=8)

### Source code
1. Open iVim.xcodeproj in Xcode
2. In General > Identity of target iVim and iVimShare, change their bundle identities to your own unique ones, and select your Apple ID to sign them. As to the App Group, it requires a paid Apple ID. If yours is, change the App Group identifier for these two targets to your own; if not, just turn them off (the only difference is that you cannot share text to iVim when it is off)
3. Connect your device via USB to your computer, and select it as the Destination of iVim
4. Run iVim, Xcode will install it onto your device
5. A free Apple ID may need to do this every 7 days
6. **Note** that the source code may not be updated as the App Store version.

### Building this fork

The frameworks for external commands, `:terminal` and the `ivish` shell
aren't part of the repository. Before the first build, fetch and build
them into `Frameworks/` (needs Xcode, git, curl, unzip):

    scripts/fetch-frameworks.sh

This downloads [ios_system](https://github.com/holzschu/ios_system) and
builds [ivish](https://github.com/terrychou/ivish), patched to work with
upstream ios_system. Re-running it only redoes what changed.

Python is not included yet.

## Quick tips

### My .vimrc file was messed up, now iVim won't start. What can I do other than reinstall it?
You can go to `iVim` in the system's `Settings` app, put `-u None` into `Arguments` of `LAUNCH OPTIONS` section to tell `iVim` not to load config files next time. Then try and launch `iVim`.

## Giants' shoulders

iVim was inspired by and based on 3 projects:
1. [vim - the official Vim repository](https://github.com/vim/vim)
2. [Vim port from Applidium](https://github.com/applidium/Vim)
3. [VimIOS - A port of Vim to iOS 9+](https://github.com/larki/VimIOS)

Without them, iVim wouldn't begin.

Also, without violating the copyright of Vim, feel free to make modifications to meet your own needs.
