#!/usr/bin/env python3

import sys
import os
import yt_dlp
import gzip
import shutil
from datetime import datetime
from logging.handlers import RotatingFileHandler
import logging
import re

# === Constants ===
LOG_DIR = 'yt_dlp_argv_log'
LOG_FILE = os.path.join(LOG_DIR, 'yt_dlp_argv.log')
MAX_LOG_SIZE = 10 * 1024 * 1024  # 10 MB
BACKUP_COUNT = 5

# === Custom rotating/compressing handler ===
class CompressingRotatingFileHandler(RotatingFileHandler):
    def doRollover(self):
        super().doRollover()
        for i in range(BACKUP_COUNT, 0, -1):
            rotated = f"{self.baseFilename}.{i}"
            compressed = rotated + ".gz"
            if os.path.exists(rotated) and not os.path.exists(compressed):
                with open(rotated, 'rb') as f_in, gzip.open(compressed, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
                os.remove(rotated)

# === Setup Logging ===
os.makedirs(LOG_DIR, exist_ok=True)

logger = logging.getLogger('yt_dlp_logger')
logger.setLevel(logging.INFO)
handler = CompressingRotatingFileHandler(LOG_FILE, maxBytes=MAX_LOG_SIZE, backupCount=BACKUP_COUNT)
formatter = logging.Formatter('%(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# === Function to Modify height<=?random_number Filter and Force video format to webm ===
def modify_resolution_filters(args):
    """
    Modify height<=?random_number to height<=?4320,
    and replace any (xxx/best) with (webm/best) in format filters.
    """
    def fix_height(text):
        return re.sub(r'height<=\?\d+', r'height<=?4320', text)

    def replace_format(text):
        return re.sub(r'\(\w+/best\)', r'(webm/best)', text)

    for i in range(len(args)):
        args[i] = fix_height(args[i])
        args[i] = replace_format(args[i])

    # Remove specific transformed format value if present => --no-cache-dir ...
    i = 0
    while i < len(args):
        if args[i] in ['-f', '--format']:
            if i + 1 < len(args):
                if args[i + 1] == '(webm/best)[height<=?4320][height>=?64][width>=?64]':
                    del args[i:i+2]
                    continue  # don't increment i, next item shifted in
        i += 1

    return args

# === Main Function ===
def custom_main():
    original_args = sys.argv[1:]
    filtered_args = []
    url = ''

    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]

        if arg.startswith(('http://', 'https://')):
            url = arg
            i += 1
            continue

#        if arg == '-f' and i + 1 < len(sys.argv):
#            filtered_args.extend([arg, sys.argv[i + 1]])
#            i += 2
#            continue

        if arg in ['--no-check-certificate', '--no-cache-dir', '--rm-cache-dir', '--get-url']:
            filtered_args.append(arg)

        if arg in ['-f', '--format', '-o', '--output']:
            if i + 1 < len(sys.argv):
                filtered_args.extend([arg, sys.argv[i + 1]])
                i += 1  # skip the value next loop

        i += 1

    if url:
        filtered_args.append(url)

    # Log the original arguments
    now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    log_entry = (
        f"\n[{now}] ORIGINAL ARGS:\n  {' '.join(original_args)}\n"
        f"[{now}] FILTERED ARGS:\n  {' '.join(filtered_args)}\n"
    )
    logger.info(log_entry)

    # Modify the resolution filters
    custom_filtered_args = modify_resolution_filters(filtered_args)

    # Log the custom filtered arguments
    log_entry_custom = f"[{now}] CUSTOM FILTERED ARGS:\n  {' '.join(custom_filtered_args)}\n"
    logger.info(log_entry_custom)

    # Update sys.argv with the custom filtered arguments
    sys.argv = [sys.argv[0]] + custom_filtered_args
    yt_dlp.main()

# === Entry Point Hook ===
if __package__ is None and not getattr(sys, 'frozen', False):
    import os.path
    path = os.path.realpath(os.path.abspath(__file__))
    sys.path.insert(0, os.path.dirname(os.path.dirname(path)))

if __name__ == '__main__':
    custom_main()

