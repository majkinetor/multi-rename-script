
  ------------------------------------------------------------------------
   About anytag.wdx 0.97
  ------------------------------------------------------------------------

    anytag.wdx is a content plugin for Total Commander which displays
    metadata of audio files.
    
    It can be used on Windows 2000, Windows XP and Windows 2003.
    Windows 9x/ME ar NOT supported (due to missing Unicode support).

    It supports the following audio formats:

     * AAC  - Advanced Audio Coding
                Reading of ID3v1, APEv1, APEv2
     * APE  - Monkey's Audio
                Reading of ID3v1, APEv1, APEv2 
     * FLAC - Free Lossless Audio Codec
                Reading of Vorbis Comments
     * MP3  - MPEG Audio Layer 3
                Reading of ID3v1, ID3v2, APEv1, APEv2
     * MP4  - MPEG-4
                Reading of MP4/iTunes metadata
     * M4A  - MPEG-4
                Reading of MP4/iTunes metadata
     * M4B  - MPEG-4
                Reading of MP4/iTunes metadata
     * MPC  - Musepack
                Reading of ID3v1, APEv1, APEv2
     * OFR  - OptimFROG
                Reading of ID3v1, APEv1, APEv2
     * OFS  - OptimFROG DualStream
                Reading of ID3v1, APEv1, APEv2
     * OGG  - Ogg Vorbis
                Reading of Vorbis Comments
     * SPX  - Speex
                Reading of Vorbis Comments
     * TTA  - True Audio
                Reading of ID3v1, ID3v2, APEv1, APEv2
     * WMA  - Windows Media Audio 
                Reading of WMA Tag (only with Windows Media 9 Runtime installed)
     * WV   - WavPack
                Reading of ID3v1, APEv1, APEv2
    
    
  ------------------------------------------------------------------------
   Installation
  ------------------------------------------------------------------------
 
     * Just use the auto-install feature, if you use TC >= 6.50

     Otherwise:
     * Copy "anytag.wdx" and "anytag.any" to your Total Commander 
       directory (e.g. C:\Program Files\TotalCmd) or any other directory.
     * Configuration -> Plugins -> Content Plugins -> Configure -> Add
       "anytag.wdx" from your Total Commander directory.
    

  ------------------------------------------------------------------------
   Configuration
  ------------------------------------------------------------------------

    * The antag.any template file
    
    The file "anytag.any" is a template file for the list of supported
    fields. You can add your own user-defined tag fields here, e.g. for
    displaying the disc number in the disc set, you simply append a new
    line to the configuration file and specify
	  ##=8|Disc of Set|disc
	  
	 If you want a three digit track number field, just add 
	  ##=8|Track (###)|$num(%track%,3)
	  
	 There are many other fields and scripting functions, which are also
	 used in the stand-alone tag editor Mp3tag from
	  http://www.mp3tag.de/en/
	  
	 You can get an overview of all available scripting functions here
	  http://mp3tag.de/en/help/main_scripting.html
	  
	 
	 * Settings in the standard contplug.ini
	 
	 If the field ansi is set to 1 (instead of 0) anytag.wdx uses the
	 system codepage for decoding non-unicode ID3v2 tags.


  ------------------------------------------------------------------------
   Autor
  ------------------------------------------------------------------------
  
    Florian Heidenreich 
    http://www.mp3tag.de/en/tc.html


  ------------------------------------------------------------------------
   Version History
  ------------------------------------------------------------------------

    05.06.06 Release anytag.wdx 0.97
    05.06.06   Added: full support for ID3v2.4 tags.
    10.01.06   Changed: further caching improvements.

    09.01.06 Release anytag.wdx 0.96
    09.01.06   Changed: massive speed improvements.
    09.01.06   Fixed: plugin didn't detect changes to files after these were cached.
    26.12.05   Changed: WRITER now COMPOSER for MP4 tags.
    
    04.12.05 Release anytag.wdx 0.95
    02.12.05   Changed: optimizations regarding plugin size (~ 150 KB).
    30.11.05   Fixed: technical information for WavPack lossy wasn't displayed if there was no WavPack correction file.
    30.11.05   Added: support for DISCNUMBER, TOTALDISCS and CONTENTGROUP at MP4 tags.
    30.11.05   Changed: COMPLIATION now ITUNESCOMPILATION for MP4 tags.
    27.11.05   Fixed: WMA bitrate wasn't displayed correctly on some files.
    27.11.05   Changed: arithmetic scripting functions are using 64 bit ints now to prevent overflows. 
    
    27.11.05 Release anytag.wdx 0.94
    27.11.05   Fixed: error in the anytag.any template file prevented TC from display more than 9 fields.

    24.11.05 Release anytag.wdx 0.93
    24.11.05   Added: full support for Unicode ID3v2 tags.
    24.11.05   Added: scripting functions for use in anytag.any template file.
    24.11.05   Added: ansi setting to decode non-unicode ID3v2 tags with system codepage.
    24.11.05   Changed: format of the anytag.any template file (old format is not supported anymore).
    24.11.05   Changed: Windows 9x/ME are not supported anymore (anytag.wdx 0.92 is still available for download).
    24.11.05   Changed: removed UPX compression because there are issues with binaries build by Visual Studio 2005.
    
    19.01.05 Release anytag.wdx 0.92
    19.01.05   Fixed: plugin did not read tags of Windows Media Audio files

    06.11.04 Release anytag.wdx 0.91
    06.11.04   Changed: plugin now uses an internal cache for faster lookup of the field data.

    02.11.04 Release anytag.wdx 0.90

    
  ------------------------------------------------------------------------
   License
  ------------------------------------------------------------------------
  
    anytag.wdx - Copyright ©2004-2006 Florian Heidenreich

    anytag.wdx is designed for private use and commercial use without sale
    ("Freeware"), if the following rules are respected:

    The Author, Florian Heidenreich, has no responsibility if errors
    occures in direct or indirect relation with the software.

    anytag.wdx cannot be used in a military domain or in a similar domain 
    (weapon creation, armament, etc.).

    anytag.wdx can be distributed through non-commercial channels.

    anytag.wdx can be distributed through commercial channels if the 
    author, Florian Heidenreich, agrees this delivery.

  ------------------------------------------------------------------------
