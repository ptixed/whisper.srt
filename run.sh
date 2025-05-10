#!/bin/bash

set -eo pipefail
cd "$(dirname "$0")"

if [ "$#" != "2" ]; then
    echo "Usage: $0 language-code video-to-convert"
    exit 1
fi

language=$1

mkv=$2
mp3=/tmp/$(basename "$mkv").mp3
srt=/tmp/$(basename "$mkv").srt

cleanup () {
    rm -f "$mp3"
}
trap cleanup EXIT

streams=$(ffprobe -v error -select_streams a -show_entries 'stream=index:stream_tags=language' -of csv "$mkv")
if [ $(echo "$streams" | wc -l) == 1 ]; then
    stream=1
else
    echo "There are mutiple audio streams available:"
    echo "$streams" | sed -E 's/stream,(.*),(.*)/\t\1: \2/'
    read -p "Pick stream index: " stream
fi

echo "Extracting audio stream..."
pv "$mkv" | ffmpeg -v error -i - -map 0:a:$(($stream-1)) "$mp3"

echo "Transcribing..."
./whisper.py "$language" "$mp3" | tee "$srt"

echo "Subtitles saved to $srt"
mpv --really-quiet "--sub-file=$srt" --aid=$stream "$mkv"
