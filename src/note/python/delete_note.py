"""Delete a note by ID from a JSON notes file.

Usage:
    delete_note.py <file> <note_id>

Exit codes:
    0 - note found and deleted (file updated or removed if empty)
    1 - note not found in this file
"""

import json
import os
import sys


def main():
    file_path = sys.argv[1]
    note_id = sys.argv[2]

    with open(file_path) as f:
        notes = json.load(f)

    remaining = [n for n in notes if n.get("id") != note_id]

    if len(remaining) == len(notes):
        sys.exit(1)

    if remaining:
        with open(file_path, "w") as f:
            json.dump(remaining, f, indent=2)
    else:
        os.remove(file_path)


if __name__ == "__main__":
    main()
