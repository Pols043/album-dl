#!/bin/bash
echo This will install all software required by album-dl.
echo Sudo or root is required.
apt install eyeD3 curl ffmpeg
curl -L https://yt-dl.org/downloads/latest/youtube-dl -o ./youtube-dl
chmod a+rx ./youtube-dl