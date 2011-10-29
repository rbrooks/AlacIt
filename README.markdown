## AlacIt

Apple Lossless conversion utility.  Converts FLAC and WAV audio files to Apple Lossless (ALAC) files in M4A format for importation into iTunes.

* Very Fast. An entire album in 10 or 15 seconds.
* No quality loss
* Basic metadata survives: Song, Artist, etc.
* Converts entire directories or single files.
* Puts converted files in same dir as source.

### Install

1. Ensure you have Ruby 1.9.2 installed, and [FFmpeg](http://ffmpeg.org/).
2. Put alacit.rb in `/usr/local/bin` without its extension, in other words:
  * `cp ~/Downloads/alacit.rb /usr/local/bin/alacit`. It will make it easier to type.
3. Make it executable. `chmod +x /usr/local/bin/alacit`

### Usage

**Single file:**

    alacit source.flac

Will output a file called `source.m4v` in same directory. 

**Entire directory:**

    alacit ~/Music/Artist/Album

Will convert all `.flac` and `.wav` files in that directory. 

### Dependencies

* **Ruby 1.9.2** - Untested on 1.8.
* **FFmpeg 0.8.0+** - Older versions will likely work too.
  * **On OS X:**  Get [Homebrew](http://mxcl.github.com/homebrew/) and type `brew install ffmpeg`.
  * **On Linux:** `sudo apt-get install flac ffmpeg`
  * **Windows:**  [untested]

### Copyright

Copyright (c) 2012 [Russell Brooks](http://russbrooks.com). See LICENSE.txt for further details.
