#!/usr/bin/env python3

# Execute with
# $ python3 -m yt_dlp

import sys
#
import yt_dlp
from datetime import datetime

def custom_main():
    log_file = 'yt_dlp_argv.log'

    # Step 1: Store the original arguments (excluding the script name)
    original_args = sys.argv[1:]

    # Step 2: Initialize filtered args
    filtered_args = []
    url = ''

    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]

        # Detect and extract the URL
        if arg.startswith(('http://', 'https://')):
            url = arg
            i += 1
            continue

        # Dynamically include -f and its value
        if arg == '-f' and i + 1 < len(sys.argv):
            filtered_args.append(arg)
            filtered_args.append(sys.argv[i + 1])
            i += 2
            continue

        # Keep only allowed flags
        if arg in ['--no-check-certificate', '--no-cache-dir', '--rm-cache-dir', '--get-url']:
            filtered_args.append(arg)

        i += 1

    # Append URL if found
    if url:
        filtered_args.append(url)

    # Step 3: Log both raw and filtered arguments
    try:
        with open(log_file, 'a') as f:
            now = datetime.now()
            f.write(f"\n[{now}] ORIGINAL ARGS:\n  {' '.join(original_args)}\n")
            f.write(f"[{now}] FILTERED ARGS:\n  {' '.join(filtered_args)}\n")
    except Exception as e:
        print(f"Logging failed: {e}")

    # Step 4: Replace sys.argv with filtered version and run
    sys.argv = [sys.argv[0]] + filtered_args
    yt_dlp.main()
#

if __package__ is None and not getattr(sys, 'frozen', False):
    # direct call of __main__.py
    import os.path
    path = os.path.realpath(os.path.abspath(__file__))
    sys.path.insert(0, os.path.dirname(os.path.dirname(path)))

import yt_dlp

if __name__ == '__main__':
    custom_main()
