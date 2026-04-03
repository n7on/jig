"""Get a single value from JSON by path.

Usage:
    echo "$json" | json_get.py 'appId'
    echo "$json" | json_get.py 'subscriptions.0.user.name'

Returns empty string for null/missing values.
"""

import json
import sys

from json_utils import resolve


def main():
    if len(sys.argv) < 2:
        print("Usage: json_get.py <path>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    data = json.load(sys.stdin)

    if path == ".":
        target = data
    else:
        target = resolve(data, path)

    if target is None:
        sys.exit(0)

    if isinstance(target, bool):
        print(str(target).lower())
    elif isinstance(target, (list, dict)):
        json.dump(target, sys.stdout, ensure_ascii=False)
    else:
        print(target)


if __name__ == "__main__":
    main()
