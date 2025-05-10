#!/usr/bin/env python3

import sys
from faster_whisper import WhisperModel

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} language-code audio-to-convert")
    exit(1)

model = WhisperModel("large-v3", device="cuda", compute_type="float16")

# condition_on_previous_text=False prevents whisper from getting stuck
segments, _ = model.transcribe(sys.argv[2], beam_size=5, language=sys.argv[1], condition_on_previous_text=False)

def format_timestamp(t):
    seconds = int(t)

    milliseconds = int((t - seconds) * 1000)
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    seconds = seconds % 60

    return f"{hours:02d}:{minutes:02d}:{seconds:02d},{milliseconds:03d}"

i=1
for segment in segments:
    print(i)
    print(f"{format_timestamp(segment.start)} --> {format_timestamp(segment.end)}")
    print(segment.text)
    print()
    i+=1

