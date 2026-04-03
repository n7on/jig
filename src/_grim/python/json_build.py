"""Build a JSON object from key=value pairs.

Usage:
    _grim_json_build 'name=foo' 'count=42'
    _grim_json_build --base '{"existing": true}' 'name=foo'
    _grim_json_build --int 'days=30' 'name=foo'
    _grim_json_build --bool 'active=true' 'name=foo'

Empty values are omitted. Nested keys are supported via dot notation:
    _grim_json_build 'retentionDuration.days=30'
    -> {"retentionDuration": {"days": "30"}}

Type hints: prefix key with type and colon:
    _grim_json_build 'int:count=42' 'bool:active=true' 'name=foo'
"""

import json
import sys


def set_nested(obj, path, value):
    """Set a value at a dotted path, creating intermediate dicts."""
    keys = path.split(".")
    for key in keys[:-1]:
        if key not in obj:
            obj[key] = {}
        obj = obj[key]
    obj[keys[-1]] = value


def parse_value(raw, type_hint=None):
    """Convert string value to typed value based on hint."""
    if type_hint == "int":
        return int(raw)
    if type_hint == "float":
        return float(raw)
    if type_hint == "bool":
        return raw.lower() in ("true", "1", "yes")
    if type_hint == "json":
        return json.loads(raw)
    return raw


def main():
    args = sys.argv[1:]
    base = {}
    pairs = []

    i = 0
    while i < len(args):
        if args[i] == "--base" and i + 1 < len(args):
            base = json.loads(args[i + 1])
            i += 2
        else:
            pairs.append(args[i])
            i += 1

    obj = dict(base)

    for pair in pairs:
        if "=" not in pair:
            continue
        key, value = pair.split("=", 1)

        # Skip empty values
        if not value:
            continue

        # Check for type hint (int:field=value)
        type_hint = None
        if ":" in key:
            type_hint, key = key.split(":", 1)

        set_nested(obj, key, parse_value(value, type_hint))

    json.dump(obj, sys.stdout, ensure_ascii=False)


if __name__ == "__main__":
    main()
