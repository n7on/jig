"""Find the first matching item in a JSON array.

Usage:
    # Find item where field matches value, return a specific field
    echo "$json" | json_find.py 'appRoles' 'value' 'User.Read' 'id'

    # Find item, return the whole object as JSON
    echo "$json" | json_find.py '.' 'displayName' 'myapp'
"""

import json
import sys

from json_utils import resolve, to_string


def main():
    if len(sys.argv) < 4:
        print("Usage: json_find.py <array_path> <match_field> <match_value> [return_field]", file=sys.stderr)
        sys.exit(1)

    array_path = sys.argv[1]
    match_field = sys.argv[2]
    match_value = sys.argv[3]
    return_field = sys.argv[4] if len(sys.argv) > 4 else None

    data = json.load(sys.stdin)

    # Resolve array path
    if array_path == ".":
        target = data
    else:
        target = resolve(data, array_path)

    if not isinstance(target, list):
        sys.exit(1)

    # Find first match (case-insensitive)
    match_lower = match_value.lower()
    for item in target:
        field_val = resolve(item, match_field)
        if field_val is not None and str(field_val).lower() == match_lower:
            if return_field:
                result = resolve(item, return_field)
                if result is not None:
                    print(to_string(result))
            else:
                json.dump(item, sys.stdout, ensure_ascii=False)
            sys.exit(0)

    # No match found
    sys.exit(1)


if __name__ == "__main__":
    main()
