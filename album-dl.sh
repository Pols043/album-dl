#!/bin/bash
echo This script automatically downloads playlists using youtube-dl.
DIR=./Downloads
if [ -d "$DIR" ]; then
  echo Saving to existing Downloads folder
else
  mkdir "${DIR}"
fi
read -p 'Enter album artist: ' ARTIST		# Get album artist
DIR="./Downloads/${ARTIST}"
if [ -d "$DIR" ]; then				# Check if artist already has a folder in dowload directory
  echo This artist already has a folder.
  echo Downloaded albums:
  ls "./Downloads/${ARTIST}"				# Prints out already downloaded albums
else						# If this is a new artist
  mkdir "${DIR}"					# Create new folder
fi
read -p 'Enter album name: ' ALBUM		# Get album name
read -p 'Enter album release year: ' YEAR	# and release year for ID3
DIR="./Downloads/${ARTIST}/${YEAR}-${ALBUM}"
if [ -d "$DIR" ]; then				# Check if album is already downloaded to warn user
    echo [WARNING] Folder already exists, files will be removed before download. Hit Ctrl-C to cancel.
else
    echo New folder will be created.
fi
read -p 'Enter Youtube playlist ID: ' ID	# Get playlist ID for youtube-dl
echo Updating youtube-dl...
./youtube-dl -U					# youtube-dl auto-update
if [ -d "$DIR" ]; then				# Check again if album is already dowloaded
    rm -R "${DIR}"					# Remove folder instead of warning
    mkdir "${DIR}"					# and create a new folder
else						# If album was not downloaded
    mkdir "${DIR}"					# Create new folder
fi
echo Download started

./youtube-dl --no-check-certificate --extract-audio --audio-format mp3 -o "./Downloads/${ARTIST}/${YEAR}-${ALBUM}/%(playlist_index)s-%(title)s.%(ext)s" https://www.youtube.com/playlist?list=${ID}	# Download album from youtube

cd "./Downloads/${ARTIST}/${YEAR}-${ALBUM}/"	# Operate in the downloaded album directory

for i in *.mp3 ; do				# Repeat fo each file
    FILENAME=$i						# Creates filename

    TRACKNOLONG="${FILENAME%%-*}"			# Gets the tracknumber from filename
    TRACKNO=$(echo $TRACKNOLONG | sed 's/^0*//')	# Removes leading zeros from track number

    NAME="${FILENAME//$TRACKNOLONG/}"			# Removes track number from track name
    NAME="${NAME//$ARTIST/}"				# Removes artist from track name
    NAME="${NAME%%.mp3*}"				# Removes .mp3 from track name
    NAME="${NAME%%[*}"					# Removes everything after [ symbol

    NAME="${NAME%%Lyric*}"				# Removes unwanted words
    NAME="${NAME%%lyric*}"
    NAME="${NAME%%LYRIC*}"
    NAME="${NAME%%Official*}"
    NAME="${NAME%%official*}"
    NAME="${NAME%%OFFICIAL*}"
    NAME="${NAME%%Music*}"
    NAME="${NAME%%music*}"
    NAME="${NAME%%MUSIC*}"
    NAME="${NAME%%Video*}"
    NAME="${NAME%%video*}"
    NAME="${NAME%%VIDEO*}"
    NAME="${NAME%%Audio*}"
    NAME="${NAME%%audio*}"
    NAME="${NAME%%AUDIO*}"
    NAME="${NAME%%hd*}"
    NAME="${NAME%%HD*}"

    NAME="${NAME//-}"					# Removes all - symbols
    NAME="${NAME//)}"					# Removes all ( symbols
    NAME="${NAME//(}"					# Removes all ) symbols
    NAME=`echo $NAME`					# Removes unwanted spaces

    eyeD3 "$i" -a "${ARTIST}" -A "${ALBUM}" -b "${ARTIST}" -Y ${YEAR} -t "$NAME" -n "$TRACKNO"		# Writes ID3 to mp3 file
    mv "$i" "$TRACKNOLONG"-"$NAME".mp3			# Creates friendly filename
done
echo Creating playlist...
ls -1 *.mp3 > "0-${ARTIST}-${ALBUM}.m3u"	# Generate M3U playlist
cd ./../../../