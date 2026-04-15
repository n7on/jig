"""List available packs from the registry, marking which are installed.

Usage:
    available.py <registry.json> <pack_dir>
"""

import json
import os
import sys


def main():
    if len(sys.argv) != 3:
        print("Usage: available.py <registry.json> <pack_dir>", file=sys.stderr)
        sys.exit(1)

    registry_path, pack_dir = sys.argv[1], sys.argv[2]

    if not os.path.isfile(registry_path):
        print(f"Registry not found: {registry_path}", file=sys.stderr)
        sys.exit(1)

    with open(registry_path) as f:
        entries = json.load(f)

    print("name,installed,modules,description,url")
    for entry in sorted(entries, key=lambda e: e.get("name", "")):
        name = entry.get("name", "")
        installed = "yes" if os.path.isdir(os.path.join(pack_dir, name)) else "no"
        modules = ",".join(entry.get("modules", []))
        description = entry.get("description", "")
        url = entry.get("url", "")
        print(f"{name}\t{installed}\t{modules}\t{description}\t{url}")


if __name__ == "__main__":
    main()
