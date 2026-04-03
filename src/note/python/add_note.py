"""Append a note to a JSON notes file.

Usage:
    add_note.py <file> <note_json>

Creates the file with [note] if it doesn't exist, or appends to existing array.
"""

import json
import os
import sys


def main():
    file_path = sys.argv[1]
    new_note = json.loads(sys.argv[2])

    if os.path.exists(file_path):
        with open(file_path) as f:
            notes = json.load(f)
    else:
        notes = []

    notes.append(new_note)

    with open(file_path, "w") as f:
        json.dump(notes, f, indent=2)


if __name__ == "__main__":
    main()
