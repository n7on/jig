"""Extract fields from JSON, outputting TSV or a single value.

Usage:
    # Single value extraction (no mappings)
    echo "$json" | json_extract.py 'path.to.field'

    # TSV extraction (with mappings)
    echo "$json" | json_extract.py 'path.to.array' 'name=displayName' 'trigger=retentionTrigger' 'id'
"""

import json
import sys


def resolve(obj, path):
    """Traverse a dotted path like 'retentionDuration.days' or 'subscriptions.0.user.name'."""
    for key in path.split("."):
        if obj is None:
            return None
        if isinstance(obj, list):
            try:
                obj = obj[int(key)]
            except (ValueError, IndexError):
                return None
        elif isinstance(obj, dict):
            obj = obj.get(key)
        else:
            return None
    return obj


def to_string(value):
    """Convert a value to a display string."""
    if value is None:
        return "-"
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, (list, dict)):
        return json.dumps(value, ensure_ascii=False)
    return str(value)


def parse_mappings(args):
    """Parse 'name=field' or 'field' mappings into (header, field_path) tuples."""
    mappings = []
    for arg in args:
        if "=" in arg:
            header, field = arg.split("=", 1)
            mappings.append((header, field))
        else:
            # No rename — use field name as header, lowercased
            mappings.append((arg.lower(), arg))
    return mappings


def main():
    if len(sys.argv) < 2:
        print("Usage: json_extract.py <path> [col=field ...]", file=sys.stderr)
        sys.exit(1)

    root_path = sys.argv[1]
    mapping_args = sys.argv[2:]

    data = json.load(sys.stdin)

    # Resolve root path
    if root_path == ".":
        target = data
    else:
        target = resolve(data, root_path)

    if target is None:
        sys.exit(0)

    # Single value mode — no mappings
    # Returns empty string for null (not "-") since this is used for variable assignment
    if not mapping_args:
        if target is None:
            sys.exit(0)
        print(to_string(target) if not isinstance(target, type(None)) else "")
        sys.exit(0)

    # Key/value mode — flatten object to field,value rows
    if mapping_args == ["--kv"]:
        if not isinstance(target, dict):
            print(f"--kv requires an object, got {type(target).__name__}", file=sys.stderr)
            sys.exit(1)
        print("field,value")
        for key, value in target.items():
            print(f"{key}\t{to_string(value)}")
        sys.exit(0)

    # TSV mode — with mappings
    mappings = parse_mappings(mapping_args)

    # Ensure target is iterable
    if isinstance(target, dict):
        target = [target]
    elif not isinstance(target, list):
        print(f"Expected array or object at '{root_path}', got {type(target).__name__}", file=sys.stderr)
        sys.exit(1)

    # Print headers
    print(",".join(h for h, _ in mappings))

    # Print rows
    for item in target:
        fields = []
        for _, field_path in mappings:
            value = resolve(item, field_path)
            fields.append(to_string(value))
        print("\t".join(fields))


if __name__ == "__main__":
    main()
