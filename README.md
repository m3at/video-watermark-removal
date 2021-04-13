# video-watermark-removal
Remove simple watermarks from videos with minimal setup.
Really basic, but works well enough for simple static watermarks, and can run on a laptop CPU (~x3 real-time on a 2.9GHz i5 from 2015).

Dependencies:
```sh
# FFMPEG
installer=$([[ $(uname) == "Darwin" ]] && echo brew || echo apt)
$installer install ffmpeg

# Optional, to fetch an example video
# $installer install youtube-dl

# Python libraries
python3 -m pip install numpy scipy imageio
```

Usage:
```sh
# The output will default to append "_cleaned" to the existing name
./remove_watermark.sh /somewhere/my_video.mp4 [/somewhere/output.mp4] [max_keyframes_to_extract]
```

Tested on MacOS 10.14 and Ubuntu 20.04
