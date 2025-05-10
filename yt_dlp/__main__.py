#!/usr/bin/env python3

# Execute with
# $ python3 -m yt_dlp

import sys
#
import yt_dlp
from datetime import datetime

def custom_main():
    # Initialize URL to an empty string
    url = ''

    # Iterate through sys.argv and find any URL (if any)
    for i, arg in enumerate(sys.argv):
        if arg.startswith(('https://', 'http://')):  # Check for any URL
            url = arg
            # Remove the URL from sys.argv to prevent duplication
            sys.argv.pop(i)
            break

    # Define the fixed arguments you want to keep
    filtered_args = [
        '--no-check-certificate',
        '--no-cache-dir',
        '--rm-cache-dir',
        '-f', '(mp4/best)[height<=?360][height>=?64][width>=?64]',
        '--get-url',
    ]

    # Append the URL if it was found
    if url:
        filtered_args.append(url)

    sys.argv = filtered_args  # Update sys.argv with the filtered arguments

    # Call yt-dlp with filtered arguments
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
