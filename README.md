## AlacIt

Apple Lossless conversion utility.  Converts APE, FLAC, and WAV audio files to Apple Lossless (ALAC) files in M4A format for importation into iTunes, iPhones, iPads, and iPods.

* Very Fast. An entire album in 10 to 15 seconds.
* No quality loss
* Basic metadata survives: Song, Artist, etc.
* Converts entire directories, single files, or any combination thereof.
* Puts converted files in same dir as source.

### Install

Ensure you have Ruby 1.9.2+ installed, and [FFmpeg](http://ffmpeg.org/), then type:

    gem install alacit

### Usage

#### Single Files

Convert a single file.  This outputs a file called `song.m4v` in same directory:

    alacit song.flac

Convert several individual files:

    alacit song.flac song2.flac

#### Entire Directories

Convert a single directory.  This finds and converts all `.ape`, `.flac`, and `.wav` files in that directory:

    alacit ~/Music/Artist/Album

Convert everything in current directory:

    alacit .

Convert many different directories in batch:

    alacit ~/Music/Artist/Album ~/Music/Artist/Album2 ~/Music/Artist2/Album

#### Combinations of Files and Directories

    alacit ~/Music/Artist/Album song3.flac ~/Downloads/Bjork

#### Force Overwrites

AlacIt won't overwrite existing files by default. If you need to, just force overwrites with the `--force` option:

    alacit --force song.flac
    alacit -f song.flac

### Dependencies

* **Ruby 1.9.2+**
* **FFmpeg 0.8.0+**
  * **On OS X:**  Get [Homebrew](http://mxcl.github.com/homebrew/) and type `brew install ffmpeg`.
  * **On Linux:** `sudo apt-get install flac ffmpeg`
  * **Windows:**  [untested]

### Copyright

Copyright (c) 2012 [Russell Brooks](http://russbrooks.com). See LICENSE.txt for further details.
