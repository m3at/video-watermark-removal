#!/usr/bin/env bash

set -eo pipefail

# Prepare output name
file_no_ext="${1%.*}"
extension="${1##*.}"
def_name="$file_no_ext""_cleaned.""$extension"
output_file="${2:-$def_name}"

# Get first few key frames
echo "Getting key frames..."
max_frames="${3:-50}"
keyframes_time=$(ffprobe -hide_banner -loglevel warning -select_streams v -skip_frame nokey -show_frames -show_entries frame=pkt_dts_time "$1" | grep "pkt_dts_time=" | xargs shuf -n "$max_frames" -e | awk -F  "=" '{print $2}')

# Save them as images, in a temporary directory
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'watermark_remove')
counter=0
echo -n "Extracting frames (up to: $max_frames)... "
for i in $keyframes_time; do
    if ! [[ "$i" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
        echo "Skipping unrecognize timing: $i"
        continue
    fi
    ffmpeg -y -hide_banner -loglevel error -ss "$i" -i "$1" -vframes 1 "$tmpdir/output_$counter.png"
    echo -n "$counter "
    ((counter=counter+1))
done
echo

# Abort if we couldn't extract frames for some reason
if [[ "$counter" -lt 2 ]]; then
    echo "$counter frames extracted, need at least 2, aborting."
    exit 1
fi

echo "Extracting watermark..."
./get_watermark.py "$tmpdir"

echo "Removing watermark in video..."
ffmpeg -hide_banner -loglevel warning -y -stats -i "$1" -acodec copy -vf "removelogo=$tmpdir/mask.png" "$output_file"

rm -rf "$tmpdir"

echo "Done"

exit 0
