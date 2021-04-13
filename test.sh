#!/usr/bin/env bash


set -eo pipefail

# Store samples there
mkdir -p test_samples

# Get the first 3 minutes of Spring (Blender Open Movie) after the opening credits, 720p video only
echo "Fetching sample movie"
URL=$(youtube-dl -g -f136 "https://youtu.be/WhWc3b3KhnY")
ffmpeg -hide_banner -loglevel warning -y -stats -ss 00:23 -t 03:00 -i "$URL" -c copy ./test_samples/original.mp4

# Add simple text as watermark
echo "Adding watermark"
ffmpeg -hide_banner -loglevel warning -y -stats -i ./test_samples/original.mp4 -filter_complex "[0:v]drawtext='font=sans-serif:fontsize=30:fontcolor=white:x=20:y=20:text=Watermark (TM)'" ./test_samples/watermarked.mp4

# Test watermark removal
echo "Tesing:"
echo
./remove_watermark.sh test_samples/watermarked.mp4
